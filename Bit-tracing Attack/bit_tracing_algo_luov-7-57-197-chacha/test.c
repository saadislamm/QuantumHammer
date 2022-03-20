#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <stdbool.h>

#include "parameters.h"

#include "F256Field.h"

#include "LUOV.h"

#include "api.h"

#define NUMBER_OF_KEYPAIRS 1		/* Number of keypairs that is generated during test */
#define SIGNATURES_PER_KEYPAIR 1	/* Number of times each keypair is used to sign a random document, and verify the signature */
#define VERIFICATIONS_PER_SIGNATURE 1

void* aligned_alloc(size_t, size_t);

/*
	Tests the execution of the keypair generation, signature generation and signature verification algorithms and prints timing results
*/

void compress(const FELT *data, unsigned char *out){
	int cur_in = 0;
	int cur_out = 0;
	int bits  = 0;
	uint64_t buf = 0;
	while(cur_in<VARS || bits>=8){
		if(bits >= 8){
			out[cur_out++] = (unsigned char) buf;
			bits -= 8;
			buf >>= 8;
		}
		else{
			buf |= ( (data[cur_in++] & 0x7f) << bits);
			bits += FIELD_SIZE;
		}
	}
	if(bits > 0){
		out[cur_out] = 0;
		out[cur_out] |= (unsigned char) buf;
	}
} 

void decompress(const unsigned char *data, FELT *out){
	int cur_in = 0;
	int cur_out = 0;
	int bits  = 0;
	uint64_t buf = 0;
	while(cur_out< VARS){ 
		if(bits >= FIELD_SIZE){
			out[cur_out++] = ( buf & 0x7f);
			bits -= FIELD_SIZE;
			buf >>= FIELD_SIZE;
		}
		else{
			buf |= ( ((uint64_t) data[cur_in++]) << bits);
			bits += 8;
		}
	}
} 

int main(void)
{
	int i, j, k;
	int message_size = 32;
	unsigned long long smlen;
	unsigned long long mlen;
	unsigned char m[message_size];
	unsigned char m2[message_size];
	unsigned char *pk = aligned_alloc(32,sizeof(unsigned char[CRYPTO_PUBLICKEYBYTES]));
	unsigned char *sk = aligned_alloc(32,sizeof(unsigned char[CRYPTO_SECRETKEYBYTES]));
	unsigned char *sm = aligned_alloc(32,sizeof(unsigned char[message_size + CRYPTO_BYTES]));
	uint64_t cl;

	int chacha_startup(void);

	// Print key and signature sizes
	printf("Public Key takes %d B\n", CRYPTO_PUBLICKEYBYTES );
	printf("Secret Key takes %d B\n", CRYPTO_SECRETKEYBYTES );
	printf("Signature takes %d B\n\n", CRYPTO_BYTES );

	srand((unsigned int) time(NULL));

	uint64_t genTime = 0;
	uint64_t signTime = 0;
	uint64_t verifyTime = 0;

	for (i = 0; i < NUMBER_OF_KEYPAIRS ; i++) {

		// time key pair generation
		cl = rdtsc();
		crypto_sign_keypair(pk, sk);
		genTime += rdtsc() - cl;

		for (j = 0; j < SIGNATURES_PER_KEYPAIR ; j++) {
			// pick a random message to sign
			/*for (k = 0; k < message_size; k++) {
				m[k] = ((unsigned char) rand());
			}*/
			randombytes(m, 32);	// Replaced with the above to get the same random message each time
			
			// time signing algorithm
			cl = rdtsc();
			crypto_sign(sm, &smlen, m, (unsigned long long) message_size, sk);
			signTime += rdtsc() - cl;
			printf("signed message length is %lld B\n", smlen);
			
			
			///////////////////////////////////////////////////////////////////
			printf("Returned Signature (m, s, salt) %llu B = %d + %llu + %d\n", smlen, message_size, smlen-message_size-SALT_BYTES, SALT_BYTES);
				for (int pp = 0; pp < smlen; pp++) {
					printf("%02x", sm[pp]);
				}
			printf("\n\n");
			///////////////////////////////////////////////////////////////////
			
			// time verification algorithm
			int verifs;
			cl = rdtsc();
			for(verifs = 0 ; verifs < VERIFICATIONS_PER_SIGNATURE ; verifs++){
				if (crypto_sign_open(m2, &mlen, sm, smlen, pk) != 0) {
					printf("Verification of signature Failed!\n");
				}
			}
			uint64_t a = rdtsc() - cl;
			verifyTime += a;
			
			

			
			/////////////////////BIT_TRACING_ALGORITHM/////////////////////////
			unsigned char compressed_signature[VINEGAR_VARS+OIL_VARS];		// Actual size is smlen-message_size-SALT_BYTES
			unsigned char decompressed_signature[VINEGAR_VARS+OIL_VARS];
			bool recovered = false;		
			cl = clock();
			for (int row = 0; row < VINEGAR_VARS; row++){	// VINEGAR_VARS
				printf("%i\n", row);
				for (int col = 0; col < OIL_VARS; col++){	// OIL_VARS
					
					memcpy(compressed_signature,sm+message_size, smlen-message_size-SALT_BYTES);
					decompress(compressed_signature,decompressed_signature);

					decompressed_signature[row] = decompressed_signature[row] ^ decompressed_signature[col+VINEGAR_VARS];
					compress(decompressed_signature,compressed_signature);
					memcpy(sm+message_size, compressed_signature, smlen-message_size-SALT_BYTES);
					
					if (crypto_sign_open(m2, &mlen, sm, smlen, pk) != 0) {
					decompressed_signature[row] = decompressed_signature[row] ^ decompressed_signature[col+VINEGAR_VARS];
					compress(decompressed_signature,compressed_signature);
					memcpy(sm+message_size, compressed_signature, smlen-message_size-SALT_BYTES);
					}
					else {
						printf("Bitflip is in Row %d and Column %d of T\n", row+1, col+1);
						recovered = true;
						break;
					}
				}
				if (recovered == true) {
					break;
				}
			}
			cl = clock() - cl;
			printf("\n%.3f seconds.\n", (float)cl / CLOCKS_PER_SEC);

			///////////////////////////////////////////////////////////////////
			
			
			
			
			
			// check if recovered message length is correct
			if (mlen != message_size){
				printf("Wrong message size !\n");
			}

			// check if recovered message is correct
			/*
			for(k = 0 ; k<message_size ; k++){
				if(m[k]!=m2[k]){
					printf("Wrong message !\n");
					break;
				}
			}
			*/
		}

	}

	//printf("Key pair generation took %llu cycles.\n",(long long unsigned) genTime / NUMBER_OF_KEYPAIRS);
	//printf("Signing took %llu cycles.\n", (long long unsigned) (signTime/NUMBER_OF_KEYPAIRS)/SIGNATURES_PER_KEYPAIR );
	//printf("Verifying took %llu cycles.\n\n", (long long unsigned) (verifyTime / NUMBER_OF_KEYPAIRS) / SIGNATURES_PER_KEYPAIR / VERIFICATIONS_PER_SIGNATURE );

	free(pk);
	free(sk);
	free(sm);

	return 0;
}
