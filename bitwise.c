#include <stdio.h>
#define SIZE_INT 16

void printBitArray (unsigned char theBits[SIZE_INT]) {
  int i; //loop counter
  for (i = 0; i < SIZE_INT; i++) {
    printf("%d", theBits[i]);
  }
}

void toBits (unsigned short value,unsigned char inBits[SIZE_INT]) {

  //justTheBit is declared to be the integer that holds
  //the specific bit to which we are comparing the mask.
  int justTheBit = 0;
  int i; //loop counter
  int j = 0; //counter for the inBits array

  for (i = 15; i >= 0; i--) {

    //shifts the value right i times so we only look at 1 bit at a time
    justTheBit = value >> i;

    //matches the current bit with a mask of 1 using the bitwise
    //AND operation (&) to see if the current bit is a 1 or a 0
    if (justTheBit & 1) {
      inBits[j] = 1;
    } else {
      inBits[j] = 0;
    } //if else statement ends
    j++;
  } //for loop ends
}

int main() {
  printf("program is starting");
  unsigned char bits[SIZE_INT] = {0};
  toBits(25,bits);
  printBitArray(bits);
  printf("program is complete");

}
