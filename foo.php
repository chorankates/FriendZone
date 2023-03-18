<?php

// Store a string into the variable which
// need to be Encrypted
//$simple_string = "Welcome to GeeksforGeeks\n";

// Display the original string
//echo "Original String: " . $simple_string;

  $encryption = "T0lNRlhxdzR6STE2NjI0MTA0NDQxTTk2TXJsaVhi"; // original
  //$encryption = 'OIMFXqw4zI16624104441M96MrliXb'; // base64 decoded
// Store the cipher method
  $ciphering = "AES-128-CTR";

// Use OpenSSl Encryption method
  $iv_length = openssl_cipher_iv_length($ciphering);
  $options = 0;

// Non-NULL Initialization Vector for encryption
  //$decryption_iv = '1662410444'; // 10
  //$decryption_iv = 'Mon, 05 Sep 2022 20:40:44 GMT'; // 29
  //$decryption_iv = '22-09-05 20:40:44'; // 17
  $decryption_iv = '22-09-0520:40:44'; // 17

// Store the encryption key
  $decryption_key = "justgotzoned";


// Use openssl_decrypt() function to decrypt the data
  $decryption=openssl_decrypt ($encryption, $ciphering,
        $decryption_key, $options, $decryption_iv);

// Display the decrypted string
  echo "Decrypted String: " . $decryption . "\n";

?>
