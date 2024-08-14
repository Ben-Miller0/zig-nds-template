export fn _start() noreturn {
    asm volatile ("mov sp, 0x04000000");
    main();
    while (true) {}
}

pub fn main() void {}
