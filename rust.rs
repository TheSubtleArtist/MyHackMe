// The code from the challenge section in rust.md
use std::io::{self, BufRead};

fn main() {
    println!("Please enter the ROT13-encoded input:");

    let stdin = io::stdin();
    let mut lines = stdin.lines();

    let input = match lines.next() {
        Some(Ok(line)) => line.trim().to_string(),
        _ => {
            println!("No input received.");
            return;
        }
    };

    // Step 1: The input we received is already ROT13-encoded
    let rot13_once = input;

    // Step 2: Decode ROT13 → should give us a Base64 string
    let base64_str = decode_rot13(&rot13_once);

    // Step 3: Decode Base64 → should give us another ROT13 string
    let rot13_twice = match base64::decode(&base64_str) {
        Ok(bytes) => match String::from_utf8(bytes) {
            Ok(s) => s,
            Err(e) => {
                eprintln!("Base64 contained invalid UTF-8: {}", e);
                return;
            }
        },
        Err(e) => {
            eprintln!("Invalid Base64 input: {}", e);
            return;
        }
    };

    // Step 4: Decode ROT13 again → should give us the final plaintext
    let plaintext = decode_rot13(&rot13_twice);

    println!("\nResults:");
    println!("  Input (ROT13)          : {}", rot13_once);
    println!("  After first ROT13 decode (Base64): {}", base64_str);
    println!("  After Base64 decode    (ROT13)  : {}", rot13_twice);
    println!("  Final plaintext        : {}", plaintext);
}

fn decode_rot13(s: &str) -> String {
    s.chars()
        .map(|c| match c {
            'A'..='Z' => {
                let offset = (c as u8 - b'A' + 13) % 26;
                (b'A' + offset) as char
            }
            'a'..='z' => {
                let offset = (c as u8 - b'a' + 13) % 26;
                (b'a' + offset) as char
            }
            _ => c,
        })
        .collect()
}