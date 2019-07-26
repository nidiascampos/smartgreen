# This file is part of the Python aiocoap library project.
#
# Copyright (c) 2012-2014 Maciej Wasilak <http://sixpinetrees.blogspot.com/>,
#               2013-2014 Christian Amsüss <c.amsuess@energyharvesting.at>
#
# aiocoap is free software, this file is published under the MIT license as
# described in the accompanying LICENSE file.

"""This module contains the tools to send OSCORE secured messages.

It only deals with the algorithmic parts, the security context and protection
and unprotection of messages. It does not touch on the integration of OSCORE in
the larger aiocoap stack of having a context or requests; that's what
:mod:`aiocoap.transports.osore` is for.`"""

import abc
import binascii
import hashlib
import json
import os
import os.path
import tempfile
import warnings

import cbor
import cryptography.exceptions
import hkdf
from aiocoap.message import Message
from aiocoap.numbers import POST, FETCH, CHANGED
from cryptography.hazmat.primitives.ciphers.aead import AESCCM

from communication.aiocoap.util import secrets

MAX_SEQNO = 2**40 - 1

# Relevant values from the IANA registry "CBOR Object Signing and Encryption (COSE)"
COSE_KID = 4
COSE_PIV = 6
# No numeric value has been assigned yet; as we're only building the protected
# and unprotected fields temporarily in untyped data structures and serializing
# them through the compression, this can stay a string until a number is
# assigned.
COSE_KID_CONTEXT = 'TBD-draft-ietf-core-object-security-14'

COMPRESSION_BITS_N = 0b111
COMPRESSION_BIT_K = 0b1000
COMPRESSION_BIT_H = 0b10000
COMPRESSION_BITS_RESERVED = 0b11100000

class NotAProtectedMessage(ValueError):
    """Raised when verification is attempted on a non-OSCORE message"""

    def __init__(self, message, plain_message):
        super().__init__(message)
        self.plain_message = plain_message

class ProtectionInvalid(ValueError):
    """Raised when verification of an OSCORE message fails"""

class DecodeError(ProtectionInvalid):
    """Raised when verification of an OSCORE message fails because CBOR or compressed data were erroneous"""

class ReplayError(ProtectionInvalid):
    """Raised when verification of an OSCORE message fails because the sequence numbers was already used"""

class RequestIdentifiers:
    """A container for details that need to be passed along from the
    (un)protection of a request to the (un)protection of the response; these
    data ensure that the request-response binding process works by passing
    around the request's partial IV.

    Users of this module should never create or interact with instances, but
    just pass them around.
    """
    def __init__(self, kid, partial_iv, nonce, can_reuse_nonce):
        self.kid = kid
        self.partial_iv = partial_iv
        self.nonce = nonce
        self.can_reuse_nonce = can_reuse_nonce

    def get_reusable_nonce(self):
        """Return the nonce if can_reuse_nonce is True, and set can_reuse_nonce
        to False."""

        if self.can_reuse_nonce:
            self.can_reuse_nonce = False
            return self.nonce
        else:
            return None

def _xor_bytes(a, b):
    assert len(a) == len(b)
    # FIXME is this an efficient thing to do, or should we store everything
    # that possibly needs xor'ing as long integers with an associated length?
    return bytes(_a ^ _b for (_a, _b) in zip(a, b))

class Algorithm(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def encrypt(cls, plaintext, aad, key, iv):
        """Return ciphertext + tag for given input data"""

    @abc.abstractmethod
    def decrypt(cls, ciphertext_and_tag, aad, key, iv):
        """Reverse encryption. Must raise ProtectionInvalid on any error
        stemming from untrusted data."""

class AES_CCM(Algorithm, metaclass=abc.ABCMeta):
    """AES-CCM implemented using the Python cryptography library"""

    @classmethod
    def encrypt(cls, plaintext, aad, key, iv):
        return AESCCM(key, cls.tag_bytes).encrypt(iv, plaintext, aad)

    @classmethod
    def decrypt(cls, ciphertext_and_tag, aad, key, iv):
        try:
            return AESCCM(key, cls.tag_bytes).decrypt(iv, ciphertext_and_tag, aad)
        except cryptography.exceptions.InvalidTag:
            raise ProtectionInvalid("Tag invalid")

class AES_CCM_64_64_128(AES_CCM):
    # from RFC8152 and draft-ietf-core-object-security-0[012] 3.2.1
    value = 12
    key_bytes = 16 # 128 bit, the 'k' column
    iv_bytes = 7 # 56 bit nonce. Implies the 64bit (8 bytes = 15 - 7) in the 'L' column
    tag_bytes = 8 # 64 bit tag, the 'M' column

class AES_CCM_16_64_128(AES_CCM):
    # from RFC8152
    value = 10
    key_bytes = 16 # 128 bit, the 'k' column
    iv_bytes = 13 # from L=16 column: 15 - L/8 = 13, and the description
    tag_bytes = 8 # 64 bit tag, the 'M' column

algorithms = {
        'AES-CCM-16-64-128': AES_CCM_16_64_128(),
        'AES-CCM-64-64-128': AES_CCM_64_64_128(),
        }

hashfunctions = {
        'sha256': hashlib.sha256,
        }

class SecurityContext:
    # FIXME: define an interface for that

    # Indicates that in this context, when responding to a request, will always
    # be the *only* context that does. (This is primarily a reminder to stop
    # reusing nonces once multicast is implemented).
    is_unicast = True

    # message processing

    def _extract_external_aad(self, message, request_kid, request_piv):
        # If any option were actually Class I, it would be something like
        #
        # the_options = pick some of(message)
        # class_i_options = Message(the_options).opt.encode()

        oscore_version = 1
        class_i_options = b""

        external_aad = [
                oscore_version,
                [self.algorithm.value],
                request_kid,
                request_piv,
                class_i_options,
                ]

        external_aad = cbor.dumps(external_aad)

        return external_aad

    def _split_message(self, message):
        """Given a protected message, return the outer message that contains
        all Class I and Class U options (but without payload or Object-Security
        option), and a proto-inner message that contains all Class E options.

        This leaves the messages' remotes unset."""

        if message.code.is_request():
            outer_host = message.opt.uri_host
            proxy_uri = message.opt.proxy_uri

            inner_message = message.copy(
                    uri_host=None,
                    uri_port=None,
                    proxy_uri=None,
                    proxy_scheme=None,
                    )
            inner_message.remote = None

            if proxy_uri is not None:
                # Use set_request_uri to split up the proxy URI into its
                # components; extract, preserve and clear them.
                inner_message.set_request_uri(proxy_uri, set_uri_host=False)
                if inner_message.opt.proxy_uri is not None:
                    raise ValueError("Can not split Proxy-URI into options")
                outer_uri = inner_message.remote.uri_base
                inner_message.remote = None
                inner_message.opt.proxy_scheme = None

            if message.opt.observe is None:
                outer_code = POST
            else:
                outer_code = FETCH
        else:
            outer_host = None
            proxy_uri = None

            inner_message = message.copy()

            outer_code = CHANGED

        # no max-age because these are always successsful responses
        outer_message = Message(code=outer_code,
                uri_host=outer_host,
                observe=None if message.code.is_response() else message.opt.observe,
                )
        if proxy_uri is not None:
            outer_message.set_request_uri(outer_uri)

        return outer_message, inner_message

    def _build_new_nonce(self):
        """This implements generation of a new nonce, assembled as per Figure 5
        of draft-ietf-core-object-security-06. Returns the shortened partial IV
        as well."""
        seqno = self.new_sequence_number()

        partial_iv = seqno.to_bytes(5, 'big')

        return (self._construct_nonce(partial_iv, self.sender_id), partial_iv.lstrip(b'\0') or b'\0')

    def _construct_nonce(self, partial_iv_short, piv_generator_id):
        pad_piv = b"\0" * (5 - len(partial_iv_short))

        s = bytes([len(piv_generator_id)])
        pad_id = b'\0' * (self.algorithm.iv_bytes - 6 - len(piv_generator_id))

        components = s + \
                pad_id + \
                piv_generator_id + \
                pad_piv + \
                partial_iv_short

        nonce = _xor_bytes(self.common_iv, components)

        return nonce

    @staticmethod
    def _compress(unprotected, protected):
        """Pack the untagged COSE_Encrypt0 object described by the arguments
        into two bytestrings suitable for the Object-Security option and the
        message body"""

        if protected:
            raise RuntimeError("Protection produced a message that has uncompressable fields.")

        piv = unprotected.pop(COSE_PIV, b"")
        if len(piv) > COMPRESSION_BITS_N:
            raise ValueError("Can't encode overly long partial IV")

        firstbyte = len(piv)
        if COSE_KID in unprotected:
            firstbyte |= COMPRESSION_BIT_K
            kid_data = unprotected.pop(COSE_KID)
        else:
            kid_data = b""

        if COSE_KID_CONTEXT in unprotected:
            firstbyte |= COMPRESSION_BIT_H
            kid_context = unprotected.pop(COSE_KID_CONTEXT)
            s = len(kid_context)
            if s > 255:
                raise ValueError("KID Context too long")
            s_kid_context = bytes((s,)) + kid_context
        else:
            s_kid_context = b""

        if unprotected:
            raise RuntimeError("Protection produced a message that has uncompressable fields.")

        if firstbyte:
            return bytes([firstbyte]) + piv + s_kid_context + kid_data
        else:
            return b""

    def protect(self, message, request_id=None, *, kid_context=True):
        """Given a plain CoAP message, create a protected message that contains
        message's options in the inner or outer CoAP message as described in
        OSCOAP.

        If the message is a response to a previous message, the additional data
        from unprotecting the request are passed in as request_id. When
        request data is present, its partial IV is reused if possible. The
        security context's ID context is encoded in the resulting message
        unless kid_context is explicitly set to a False; other values for the
        kid_context can be passed in as byte string in the same parameter.
        """

        assert (request_id is None) == message.code.is_request()

        outer_message, inner_message = self._split_message(message)

        protected = {}
        nonce = None
        unprotected = {}
        if request_id is not None:
            nonce = request_id.get_reusable_nonce()

        if nonce is None:
            nonce, partial_iv_short = self._build_new_nonce()

            unprotected[COSE_PIV] = partial_iv_short

        if message.code.is_request():
            unprotected[COSE_KID] = self.sender_id

            request_id = RequestIdentifiers(self.sender_id, partial_iv_short, nonce, can_reuse_nonce=None)

            if kid_context is True:
                if self.id_context is not None:
                    unprotected[COSE_KID_CONTEXT] = self.id_context
            elif kid_context is not False:
                unprotected[COSE_KID_CONTEXT] = kid_context

        assert protected == {}
        protected_serialized = b'' # were it into an empty dict, it'd be the cbor dump
        enc_structure = ['Encrypt0', protected_serialized, self._extract_external_aad(outer_message, request_id.kid, request_id.partial_iv)]
        aad = cbor.dumps(enc_structure)
        key = self.sender_key

        plaintext = bytes([inner_message.code]) + inner_message.opt.encode()
        if inner_message.payload:
            plaintext += bytes([0xFF])
            plaintext += inner_message.payload


        ciphertext_and_tag = self.algorithm.encrypt(plaintext, aad, key, nonce)

        option_data = self._compress(unprotected, protected)

        outer_message.opt.object_security = option_data
        outer_message.payload = ciphertext_and_tag

        # FIXME go through options section

        # the request_id in the second argument should be discarded by the
        # caller when protecting a response -- is that reason enough for an
        # `if` and returning None?
        return outer_message, request_id

    def unprotect(self, protected_message, request_id=None):
        assert (request_id is not None) == protected_message.code.is_response()

        protected_serialized, protected, unprotected, ciphertext = self._extract_encrypted0(protected_message)

        if protected:
            raise ProtectionInvalid("The protected field is not empty")

        # FIXME check for duplicate keys in protected

        if unprotected.pop(COSE_KID, self.recipient_id) != self.recipient_id:
            # for most cases, this is caught by the session ID dispatch, but in
            # responses (where explicit sender IDs are atypical), this is a
            # valid check
            raise ProtectionInvalid("Sender ID does not match")

        if COSE_PIV not in unprotected:
            if request_id is None:
                raise ProtectionInvalid("No sequence number provided in request")

            nonce = request_id.nonce
            seqno = None # sentinel for not striking out anyting
        else:
            partial_iv_short = unprotected[COSE_PIV]

            seqno = int.from_bytes(partial_iv_short, 'big')

            if not self.recipient_replay_window.is_valid(seqno):
                # If here we ever implement something that accepts memory loss
                # as in 7.5.2 ("Losing Part of the Context State" / "Replay
                # window"), or an optimization that accepts replays to avoid
                # storing responses for EXCHANGE_LIFETIM, can_reuse_nonce a few
                # lines down needs to take that into consideration.
                raise ReplayError("Sequence number was re-used")

            nonce = self._construct_nonce(partial_iv_short, self.recipient_id)

            if request_id is None: # ie. we're unprotecting a request
                request_id = RequestIdentifiers(self.recipient_id, partial_iv_short, nonce, can_reuse_nonce=self.is_unicast)

        # FIXME is it an error for additional data to be present in unprotected?

        if len(ciphertext) < self.algorithm.tag_bytes + 1: # +1 assures access to plaintext[0] (the code)
            raise ProtectionInvalid("Ciphertext too short")

        enc_structure = ['Encrypt0', protected_serialized, self._extract_external_aad(protected_message, request_id.kid, request_id.partial_iv)]
        aad = cbor.dumps(enc_structure)

        plaintext = self.algorithm.decrypt(ciphertext, aad, self.recipient_key, nonce)

        if seqno is not None:
            self.recipient_replay_window.strike_out(seqno)

        # FIXME add options from unprotected

        unprotected_message = Message(code=plaintext[0])
        unprotected_message.payload = unprotected_message.opt.decode(plaintext[1:])

        if unprotected_message.code.is_request():
            if protected_message.opt.observe != 0:
                unprotected_message.opt.observe = None
        else:
            if protected_message.opt.observe is not None:
                # -1 ensures that they sort correctly in later reordering
                # detection. Note that neither -1 nor high (>3 byte) sequence
                # numbers can be serialized in the Observe option, but they are
                # in this implementation accepted for passing around.
                unprotected_message.opt.observe = -1 if seqno is None else seqno

        return unprotected_message, request_id

    @staticmethod
    def _uncompress(option_data):
        if option_data == b"":
            firstbyte = 0
        else:
            firstbyte = option_data[0]
            tail = option_data[1:]

        unprotected = {}

        if firstbyte & COMPRESSION_BITS_RESERVED:
            raise DecodeError("Protected data uses reserved fields")

        pivsz = firstbyte & COMPRESSION_BITS_N
        if pivsz:
            if len(tail) < pivsz:
                raise DecodeError("Partial IV announced but not present")
            unprotected[COSE_PIV] = tail[:pivsz]
            tail = tail[pivsz:]

        if firstbyte & COMPRESSION_BIT_H:
            # kid context hint
            s = tail[0]
            if len(tail) - 1 < s:
                raise DecodeError("Context hint announced but not present")
            unprotected[COSE_KID_CONTEXT] = tail[1:s+1]
            tail = tail[s+1:]

        if firstbyte & COMPRESSION_BIT_K:
            kid = tail
            unprotected[COSE_KID] = kid

        return b"", {}, unprotected

    @classmethod
    def _extract_encrypted0(cls, message):
        if message.opt.object_security is None:
            raise NotAProtectedMessage("No Object-Security option present", message)

        protected_serialized, protected, unprotected = cls._uncompress(message.opt.object_security)
        return protected_serialized, protected, unprotected, message.payload

    # sequence number handling

    def new_sequence_number(self):
        retval = self.sender_sequence_number
        if retval >= MAX_SEQNO:
            raise ValueError("Sequence number too large, context is exhausted.")
        self.sender_sequence_number += 1
        # FIXME maybe _store now?
        return retval

    # context parameter setup

    def _kdf(self, master_salt, master_secret, role_id, out_type):
        out_bytes = {'Key': self.algorithm.key_bytes, 'IV': self.algorithm.iv_bytes}[out_type]

        info = cbor.dumps([
            role_id,
            self.id_context,
            self.algorithm.value,
            out_type,
            out_bytes
            ])
        extracted = hkdf.hkdf_extract(master_salt, master_secret, hash=self.hashfun)
        expanded = hkdf.hkdf_expand(extracted, info=info, hash=self.hashfun,
                length=out_bytes)
        return expanded

    def derive_keys(self, master_salt, master_secret):
        """Populate sender_key, recipient_key and common_iv from the algorithm,
        hash function and id_context already configured beforehand, and from
        the passed salt and secret."""

        self.sender_key = self._kdf(master_salt, master_secret, self.sender_id, 'Key')
        self.recipient_key = self._kdf(master_salt, master_secret, self.recipient_id, 'Key')

        self.common_iv = self._kdf(master_salt, master_secret, b"", 'IV')

class ReplayWindow:
    # FIXME: interface, abc
    pass

# FIXME: This is not a default DTLS replay window, and it should not be
# expected that this can be used in any security context.
class SimpleReplayWindow(ReplayWindow):
    """A ReplayWindow that keeps its seen sequence numbers in a sorted list;
    all entries of the list and all numbers smaller than the first entry are
    considered seen.

    This is not very efficient, but easy to understand and to serialize.

    >>> w = SimpleReplayWindow()
    >>> w.strike_out(5)
    >>> w.is_valid(3)
    True
    >>> w.is_valid(5)
    False
    >>> w.strike_out(0)
    >>> print(w.seen)
    [0, 5]
    >>> w.strike_out(1)
    >>> w.strike_out(2)
    >>> print(w.seen)
    [2, 5]
    >>> w.is_valid(1)
    False
    """
    window_count = 64 # not a window size: window size would be size of a bit field, while this is the size of the ones

    def __init__(self, seen=None):
        if not seen: # including empty-list case
            self.seen = [-1]
        else:
            self.seen = sorted(seen)

    def is_valid(self, number):
        if number < self.seen[0]:
            return False
        return number not in self.seen

    def strike_out(self, number):
        if not self.is_valid(number):
            raise ValueError("Sequence number is not valid any more and "
                    "thus can't be removed from the window")
        for i, n in enumerate(self.seen):
            if n > number:
                break
        else:
            i = i + 1
        self.seen.insert(i, number)
        assert self.seen == sorted(self.seen)
        # cleanup
        while len(self.seen) > 1 and (
                len(self.seen) > self.window_count or
                self.seen[0] + 1 == self.seen[1]
                ):
            self.seen.pop(0)

class FilesystemSecurityContext(SecurityContext):
    """Security context stored in a directory as distinct files containing
    containing

    * Master secret, master salt, the sender IDs of the participants, and
      optionally algorithm, the KDF hash function, and replay window size
      (settings.json and secrets.json, where the latter is typically readable
      only for the user)
    * sequence numbers and replay windows (sequence.json, the only file the
      process needs write access to)

    The static parameters can all either be placed in settings.json or
    secrets.json, but must not be present in both; the presence of either file
    is sufficient.

    The static files are phrased in a way that allows using the same files for
    server and client; only by passing "client" or "server" as role parameter
    at load time, the IDs are are assigned to the context as sender or
    recipient ID. (The sequence number file is set up in a similar way in
    preparation for multicast operation; but is not yet usable from a directory
    shared between server and client; when multicast is actually explored, the
    sequence file might be renamed to contain the sender ID for shared use of a
    directory).

    Note that the sequence number file is updated in an atomic fashion which
    requires file creation privileges in the directory. If privilege separation
    between settings/key changes and sequence number changes is desired, one
    way to achieve that on Linux is giving the aiocoap process's user group
    write permissions on the directory and setting the sticky bit on the
    directory, thus forbidding the user to remove the settings/secret files not
    owned by him.
    """

    class LoadError(ValueError):
        """Exception raised with a descriptive message when trying to load a
        faulty security context"""

    def __init__(self, basedir, role):
        self.basedir = basedir
        try:
            self._load(role)
        except KeyError as k:
            raise self.LoadError("Configuration key missing: %s"%(k.args[0],))

    def _load(self, my_role):
        # doesn't check for KeyError on every occasion, relies on __init__ to
        # catch that

        data = {}
        for readfile in ("secret.json", "settings.json"):
            try:
                with open(os.path.join(self.basedir, readfile)) as f:
                    filedata = json.load(f)
            except FileNotFoundError:
                continue

            for (key, value) in filedata.items():
                if key.endswith('_hex'):
                    key = key[:-4]
                    value = binascii.unhexlify(value)
                elif key.endswith('_ascii'):
                    key = key[:-6]
                    value = value.encode('ascii')

                if key in data:
                    raise self.LoadError("Datum %r present in multiple input files at %r."%(key, self.basedir))

                data[key] = value

        self.algorithm = algorithms[data.get('algorithm', 'AES-CCM-64-64-128')]
        self.hashfun = hashfunctions[data.get('kdf-hashfun', 'sha256')]

        if my_role == 'server':
            self.sender_id = data['server-sender-id']
            self.recipient_id = data['client-sender-id']
        elif my_role == 'client':
            self.sender_id = data['client-sender-id']
            self.recipient_id = data['server-sender-id']
        else:
            raise self.LoadError("Unknown role")

        if max(len(self.sender_id), len(self.recipient_id)) > self.algorithm.iv_bytes - 6:
            raise self.LoadError("Sender or Recipient ID too long (maximum length %s for this algorithm)" % (self.algorithm.iv_bytes - 6))

        master_secret = data['secret']
        master_salt = data.get('salt', b'')
        self.id_context = data.get('id-context', None)

        self.derive_keys(master_salt, master_secret)

        try:
            with open(os.path.join(self.basedir, 'sequence.json')) as f:
                sequence = json.load(f)
        except FileNotFoundError:
            self.sender_sequence_number = 0
            self.recipient_replay_window = SimpleReplayWindow([])
        else:
            sender_hex = binascii.hexlify(self.sender_id).decode('ascii')
            recipient_hex = binascii.hexlify(self.recipient_id).decode('ascii')
            self.sender_sequence_number = int(sequence['used'][sender_hex])
            self.recipient_replay_window = SimpleReplayWindow([int(x) for x in
                sequence['seen'][recipient_hex]])
            if len(sequence['used']) != 1 or len(sequence['seen']) != 1:
                warnings.warn("Sequence files shared between roles are "
                        "currently not supported.")

    # FIXME when/how will this be called?
    #
    # it might be practical to make sender_sequence_number and recipient_replay_window
    # properties private, and provide access to them in a way that triggers
    # store or at least a delayed store.
    def _store(self):
        tmphand, tmpnam = tempfile.mkstemp(dir=self.basedir,
                prefix='.sequence-', suffix='.json', text=True)

        sender_hex = binascii.hexlify(self.sender_id).decode('ascii')
        recipient_hex = binascii.hexlify(self.recipient_id).decode('ascii')

        with os.fdopen(tmphand, 'w') as tmpfile:
            tmpfile.write('{\n'
                '  "used": {"%s": %d},\n'
                '  "seen": {"%s": %s}\n}'%(
                sender_hex, self.sender_sequence_number,
                recipient_hex, self.recipient_replay_window.seen))

        os.rename(tmpnam, os.path.join(self.basedir, 'sequence.json'))

    @classmethod
    def generate(cls, basedir):
        """Create a security context directory from default parameters and a
        random key; it is an error if that directory already exists.

        No SecurityContext object is returned immediately, as it is expected
        that the generated context can't be used immediately but first needs to
        be copied to another party and then can be opened in either the sender
        or the recipient role."""
        # shorter would probably be OK too (that token might be suitable to
        # even skip extraction), but for the purpose of generating conformant
        # example contexts.
        master_secret = secrets.token_bytes(nbytes=32)

        os.makedirs(basedir)
        with open(os.path.join(basedir, 'settings.json'), 'w') as settingsfile:
            settingsfile.write("{\n"
                    '  "server-id_hex": "00",\n'
                    '  "client-id_hex": "01",\n'
                    '  "algorithm": "AES-CCM-16-64-128",\n'
                    '  "kdf-hashfun": "sha256"\n'
                    '}')

        # atomicity is not really required as this is a new directory, but the
        # readable-by-us-only property is easily achieved with mkstemp
        tmphand, tmpnam = tempfile.mkstemp(dir=basedir, prefix='.secret-',
                suffix='.json', text=True)
        with os.fdopen(tmphand, 'w') as secretfile:
            secretfile.write("{\n"
                    '  "secret_hex": "%s"\n'
                    '}'%binascii.hexlify(master_secret).decode('ascii'))
        os.rename(tmpnam, os.path.join(basedir, 'secret.json'))

def verify_start(message):
    """Extract a sender ID and ID context (if present, otherwise None) from a
    message for the verifier to then pick a security context to actually verify
    the message.

    Call this only requests; for responses, you'll have to know the security
    context anyway, and there is usually no information to be gained."""

    _, _, unprotected, _ = SecurityContext._extract_encrypted0(message)

    try:
        # FIXME raise on duplicate key
        return unprotected[COSE_KID], unprotected.get(COSE_KID_CONTEXT, None)
    except KeyError:
        raise NotAProtectedMessage("No Sender ID present", message)

