#test-helpers.jl

#test __frac_trim(frac, fsize) - this is a function solely used in the
#constructor. __frac_trim takes a dump of bits (frac) in superint
#and trims it down to size according to (fsize).  NB.  fsize the variable
#represents the actual number of fraction bits *minus one*.  outputs
#the new superint, the fsize (as potentially modified), and a ubit.

#in a 64-bit single width superint.  Trim for fsize = 0, i.e. down to 1 bit.
@test Unums.__frac_trim(nobits,  uint16(0)) == (nobits, 0, 0)
@test Unums.__frac_trim(allbits, uint16(0)) == (msb1  , 0, Unums.UNUM_UBIT_MASK)


#test encoding and decoding exponents
#remember, esize is the size of the exponent *minus one*.

#a helpful table.
#  esize    values     representation
#------------------------------------
#   0        0          <denormal>
#            1          0
#------------------------------------
#   1        00         <denormal>
#            01         -1
#            10         0
#            11         1
#------------------------------------
#   2        000        <denormal>
#            001        -3
#            010        -2
#            011        -1
#            100        0
#            101        1
#            110        2
#            111        3
#------------------------------------
#   3        0000       <denormal>
#            0001       -7
#            0010       -6
#  etc.

#spot checking exponent encoding for intent.
@test (0, 1) == Unums.encode_exp(0)
@test (1, 1) == Unums.encode_exp(-1)
@test (1, 3) == Unums.encode_exp(1)
@test (2, 1) == Unums.encode_exp(-3)
@test (2, 6) == Unums.encode_exp(2)
@test (3, 1) == Unums.encode_exp(-7)
@test (3, 13) == Unums.encode_exp(5)

println("hi mom")
#comprehensive checking of all exponents in the range -2^-6..2^6

for e = -1000:1000
  @test e == Unums.decode_exp(Unums.encode_exp(e)...)
end