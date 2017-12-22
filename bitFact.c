/*
 ============================================================================
 Name: Ryan Russell
 UVicID: V00873387
 Date: Sep. 19th, 2017
 Assignment: CSC 230 Assignment 2
 File name: bitFact.c
 Description: This program takes an inputted integer, calculates its
 factorial and outputs the number in both decimal and binary.
 ============================================================================
 */

// Preprocessor Directives
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define SIZE_INT 16

/* @param: unsigned char theBits[SIZE_INT]
 * An array of unsigned chars that describes a number in binary format
 * is accepted and is printed out.
 */
void printBitArray (unsigned char theBits[SIZE_INT]) {

  printf("The factorial of the inputted number is 0b");

  int i; //loop counter
  for (i = 0; i < SIZE_INT; i++) {
    printf("%u", theBits[i]);
  }

  printf(" in binary.\n\n");
}

/* @param: unsigned char inBits[SIZE_INT]
 * @param: unsigned short value
 * The function places each of the 16 bits of unsigned short integer into
 * different array elements, in the least significant bit location.
 */
void toBits (unsigned short value,unsigned char inBits[SIZE_INT]) {
  //justTheBit is declared to be the integer that holds
  //the specific bit which we are comparing to the mask.
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

/* @param: unsigned short num
 * @return: unsigned short
 * The function accepts an unsigned short sized integer parameter, calculates
 * and returns the factorial of that value.
 */
unsigned short factorial (unsigned short num) {
    if (num == 0) {
    return 1;
  }
  return num * factorial(num - 1); //uses recursion
}

/* PRE_CONDITION: Inputted number must be a positive integer from 0 to 7.
 * The main function calls the other previously declared functions
 * to compute the factorial of a user-inputted number, place the bits
 * of this number into an array and prints the contents of that array.
 */
int main () {
  //declares and initializes an array which the bits
  //of a binary number will be inserted into later
  unsigned char bits[SIZE_INT] = {0};
  unsigned short number = 0;
  char inputString[3];

  printf("bitFact Program is Starting.\n\n");

  //this is an infinite loop so the user will be prompted to
  //make another factorial calculation once the first is complete
  while (1) {
    printf("Please input a positive integer from 0 to 8: ");
    scanf("%hu", &number); //receives user input for a positive integer.

    //computes the factorial of the inputted number
    unsigned short factResult = factorial(number);
    printf("The factorial of the inputted number is %hu in decimal\n", factResult);
    printf("The factorial of the inputted number is 0x%X in hexadecimal\n", factResult);

    //calls the toBits function to insert the bits of the
    //factResult into an array
    toBits(factResult,bits);

    //prints the contents of the created array
    printBitArray(bits);

    //this block of code performs the process in which the the user is
    //prompted to make another calculation
    printf("Do you want to compute another factorial? (yes/no): ");
    scanf("%s", inputString);
    if (strcmp(inputString,"no") == 0) { //if the user says no, exit program
      break;
    } else if (strcmp(inputString,"yes") == 0) { //if the user says yes, continue
      continue;
    } else { //else, the program ends
      printf("\nInvalid input. Program will end.");
      break;
    }
  }
  printf("\nbitFact Program is Complete.");
  return 0;
}
