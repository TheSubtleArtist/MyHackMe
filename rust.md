# Learn Rust

## What is Rust

### Fast
a compiled low level language, which aims (and succeeds) to be the same speed as C++, but while incorporating some higher level language features  

the data type of a variable is known at compile time  

Rust does not use garbage collection  

### Secure

completely memory safe

All Rust code follows these rules:

- Each value has a variable, called an owner.
- There can only be one owner at a time.
- When the owner goes out of scope, the value will be dropped.

Values can be moved or borrowed between variables, but no value can have more than 1 owner.

### Productive

Cargo: Package manager  
Clippy: development assistant  
RustFMT: automatic code formatting  
Cargo Test: built-in testing application  
Cargo docs: automatic code documentation generator; written in markdown
Rust-Analyzer: Labels wrong code, explains why the code is wrong, provides auto-fix  
The Book: Rust documentation

## Installing and Tooling


Install `:> curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

Documentation: https://rust-lang.org/tools/install/

Install rustscan with cargo: `:> cargo install rustscan`  

format code: `:> cargo fmt`  

## Hello, World!  

Create a new folder: `:> mkdir HelloWorld`

Initilize the project: `:> cargo init`  

```rust
- Cargo.toml //project configuration file
- src/
    - main.rs
```

### Cargo.toml

The Cargo.toml file for each package is called its manifest. It is written in the TOML format. It contains [metadata](https://doc.rust-lang.org/cargo/reference/manifest.html) that is needed to compile the package. Checkout the cargo locate-project section for more detail on how cargo finds the manifest file.  

### main.rs

located in `src` folder

required file
every `main.rs` must have a `main` function  

```rust
fn main() {
    println!("Hello, world!");
}
```

### Execute Code  

`:> cargo run`  

Results in increased file structure  

![first run tree](/images/rust-101.png)  

Finding the binary  

![binary](images/rust-102.png)

Run the binary: `:> ./target/debut/hello_world`  

Optimise for release: `:> carge build --release`  

![new tree](/images/rust-103.png)  


## Variables

All variables are immutable  

```rust
fn main() {
    let x = 5;
    println!("The value of x is: {}", x);
    x = 1;
    println!("The value of x is: {}", x);
}
```

This code does not compile**.** It returns with the error:

`error[E0384]: cannot assign twice to immutable variable x --> src/main.rs:4:5`

To make a variable mutable, we place the mut keyword in front of it like so: 

```rust
fn main() {     
    let mut x = 9;     
    println!("The value of x is: {}", x);     
    let x = 4;     
    println!("The value of x is: {}", x); }
```

This code compiles & runs correctly  

## Constant Variables

are always immutable  

can be declared in any scope, including the global scope. This means that we can use their value in any part of our code, or in multiple places at once  

`const HUNDRED_THOUSAND: u32 = 100_000;`  

### Shadowing

```rust
fn main(){
    let x = 6;
    let x = x + 1;
    println!("{}", x)
}
```

"The first variable is shadowed by the second"  

The program first binds `x` to the value of 6. Then it shadows `x` by repeating `let x`, taking the original value and adding 1 so the value is then 7.  

Effectively creates a new variable with the `let` command, allowing a change in type.  


Also allowed:  

```rust
let word = "hello";
let word = word.len();
```

## Data Structure

### type hinted variables

```md
arch    | integer | unsigned
8-bit   | i8      | u8
16-bit  | i16     | u16
32-bit  | i32     | u32
64-bit  | i64     | u64
128-bit | i128    | u128

```

### Strings

#### String 

growable allocated data structure

#### &str

immutable fixed-length string
is a string slice of string