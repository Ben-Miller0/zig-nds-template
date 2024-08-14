export fn _start() noreturn {
    asm volatile ("mov sp, 0x03000000");
    main();
    while (true) {}
}

const DISPCNT: *u32 = @ptrFromInt(0x04000000);
const VCOUNT: *u16 = @ptrFromInt(0x04000006);
const KEYINPUT: *u16 = @ptrFromInt(0x04000130);
const VRAMCNT_A: *u8 = @ptrFromInt(0x04000240);
const POWCNT1: *u32 = @ptrFromInt(0x04000304);
const VRAM_A: [*]u16 = @ptrFromInt(0x06800000);

fn main() void {
    POWCNT1.* = 0x00008003;

    DISPCNT.* = 0x00020000;

    VRAMCNT_A.* = 0x80;

    clear_screen(0b111110000000000);
    print_string("Hello, World!\x01");

    var f_count: u8 = 0;
    var a_count: u8 = 0;
    var a_pressed = false;
    while (true) : (f_count +%= 1) {
        cursor_x = 0;
        cursor_y = 1;
        print_string("A:");
        if (!a_pressed) {
            if (KEYINPUT.* & 1 == 0) {
                a_count +%= 1;
                a_pressed = true;
            }
        } else {
            if (KEYINPUT.* & 1 == 1) {
                a_pressed = false;
            }
        }
        print_byte(a_count);
        cursor_x = 0;
        cursor_y = 2;
        print_string("F:");
        print_byte(f_count);

        while (VCOUNT.* < 192) {}
        while (VCOUNT.* != 0) {}
    }
}

pub fn print_byte(byte: u8) void {
    print_char(switch (byte >> 4) {
        0x0 => '0',
        0x1 => '1',
        0x2 => '2',
        0x3 => '3',
        0x4 => '4',
        0x5 => '5',
        0x6 => '6',
        0x7 => '7',
        0x8 => '8',
        0x9 => '9',
        0xA => 'A',
        0xB => 'B',
        0xC => 'C',
        0xD => 'D',
        0xE => 'E',
        0xF => 'F',
        else => '\x00',
    });
    print_char(switch (byte & 0x0F) {
        0x0 => '0',
        0x1 => '1',
        0x2 => '2',
        0x3 => '3',
        0x4 => '4',
        0x5 => '5',
        0x6 => '6',
        0x7 => '7',
        0x8 => '8',
        0x9 => '9',
        0xA => 'A',
        0xB => 'B',
        0xC => 'C',
        0xD => 'D',
        0xE => 'E',
        0xF => 'F',
        else => '\x00',
    });
}

pub fn print_string(string: []const u8) void {
    for (string) |char| {
        print_char(char);
    }
}

const font = @import("font.zig");

var cursor_x: u8 = 0;
var cursor_y: u8 = 0;

pub fn print_char(char: u8) void {
    var bitmap: u64 = font.get_bitmap(char);
    const offset: u16 = (@as(u16, cursor_y) << 11) + (cursor_x << 3);
    var i: u16 = 0;
    while (i < 8) : (i += 1) {
        var j: u8 = 0;
        while (j < 8) : (j += 1) {
            if (bitmap & (1 << (64 - 1)) != 0) {
                VRAM_A[(i << 8) | j + offset] = 0b000001111111111;
            } else {
                VRAM_A[(i << 8) | j + offset] = 0b111110000000000;
            }
            bitmap <<= 1;
        }
    }
    cursor_x += 1;
    if (cursor_x >= 32) {
        cursor_x = 0;
        cursor_y += 1;
        if (cursor_y >= 24) {
            cursor_y = 0;
        }
    }
}

pub fn clear_screen(colour: u15) void {
    var i: usize = 0;

    while (i < 0x18000) : (i += 1) {
        VRAM_A[i] = colour;
    }
}
