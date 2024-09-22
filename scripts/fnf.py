#!/usr/bin/python3
from Crypto.Cipher import AES
import getopt
import sys
import os

class AESCipher:
    def __init__(self, key, iv):
        self.key = key
        self.iv = iv

    def encrypt(self, raw):
        """
        Returns encrypted block
        """
        cipher = AES.new(self.key, AES.MODE_ECB)
        encrypted = cipher.encrypt(raw)
        return encrypted

    def decrypt(self, enc):
        """
        Requires encrypted block, returns decrypted block
        """
        cipher = AES.new(self.key, AES.MODE_ECB)
        decrypted = cipher.decrypt(enc)
        return decrypted

#key = b'abcdefghijklmnop'
key = bytearray.fromhex("29B4AC18D090166559244E15548BD4C11B98D33AD57F7B0D9BFFF6CEB7CF6145") # 256-bit Festival MIDI key

iv = bytearray.fromhex("00000000000000000000000000000000") # null nonce because that's just what they do when they ECB

arglist = sys.argv[1:]
options = "dev"
long_options = ["decrypt","encrypt","verbose"]
cryptor = False
verbose = False

try:
    opts, args= getopt.getopt(arglist,options,long_options)
    for curArg,curVal in opts:
       if curArg in ("-d","--decrypt"):
          if cryptor == True:
             print("Cannot do both encryption and decryption simultaneously")
             quit()
          encrypt = False
          cryptor = True
       elif curArg in ("-e","--encrypt"):
          if cryptor == True:
             print("Cannot do both encryption and decryption simultaneously")
             quit()
          encrypt = True
          cryptor = True
       elif curArg in ("-v","--verbose"):
          verbose = True
except getopt.error as err:
    print(err)
    quit()

if (len(args) == 0) | (len(opts) == 0):
    print(os.path.basename(sys.argv[0]), "v1.0\n")
    print("Usage: [-d/-e] [-v] <file>\n")
    print("-d / --decrypt: decrypt FNF .dat to .mid")
    print("-e / --encrypt: encrypt .mid to FNF .dat")
    print("-v / --verbose: verbose output")
    print("<file>: input file to encrypt or decrypt")
    if cryptor == False:
        print("Must use one of either -e/--encrypt or -d/--decrypt")
    quit()

infile = args[0]
infilename, infileext = os.path.splitext(infile)
if encrypt:
    outfile = infilename + ".dat"
else:
    outfile = infilename + ".mid"

try:
    encfile = open(infile, "rb")
except FileNotFoundError as exc:
    print(infile + ": file not found")
    quit()

decfile = open(outfile, "wb")

if verbose:
    print("AES key is",key.hex())
if encrypt:
    print("Encrypting",os.path.basename(infile),"to",os.path.basename(outfile))
else:
    print("Decrypting",os.path.basename(infile),"to",os.path.basename(outfile))

c = AESCipher(key, iv)

count=0

while True:
    block = encfile.read(16)
    if block:
        count += 1
    elif not block:
        break
    if len(block) < 16:
        blockpad = 16 - len(block)
        print("Final block is",len(block),"bytes, adding",blockpad,"padding bytes")
        tempblock = bytearray(16)
        for b in range(0,len(block)):
            tempblock[b] = block[b]
        block = bytes(tempblock)
    if encrypt:
       ptxt = c.encrypt(block)
       if verbose:
           print("Block",count,": DEC:",block.hex(),"ENC:",ptxt.hex())
    else:
       ptxt = c.decrypt(block)
       if verbose:
           print("Block",count,": ENC:",block.hex(),"DEC:",ptxt.hex())
    decfile.write(ptxt)

if encrypt:
    print("Encrypted",count,"blocks")
if not encrypt:
    print("Decrypted",count,"blocks")

print("Closing files...")
encfile.close()
decfile.close()
print("Done!")
