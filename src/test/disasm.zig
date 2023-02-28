const std = @import("std");
const testing = std.testing;

const Disassembler = @import("../Disassembler.zig");

test "disassemble" {
    const gpa = testing.allocator;
    var disassembler = Disassembler.init(&.{
        // zig fmt: off
        0x48, 0xb8, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x41, 0xbc, 0xf0, 0xff, 0xff, 0xff,
        0x49, 0x89, 0xC4,
        0x4C, 0x89, 0x25, 0xF0, 0xFF, 0xFF, 0xFF,
        0x4C, 0x89, 0x1d, 0xf0, 0xff, 0xff, 0xff,
        0x49, 0x89, 0x43, 0xf0,
        0x46, 0x88, 0x5C, 0xE5, 0xF0,
        0x4c, 0x8b, 0x65, 0xf0,
        0x48, 0x8b, 0x85, 0x00, 0xf0, 0xff, 0xff,
        0x48, 0x8b, 0x18,
        0xc6, 0x45, 0xf0, 0x10,
        0x49, 0xc7, 0x43, 0xf0, 0x10, 0x00, 0x00, 0x00,
        0x48, 0x8d, 0x45, 0xf0,
        0x41, 0x8d, 0x43, 0x10,
        0x4c, 0x8d, 0x25, 0x00, 0x00, 0x00, 0x00,
        0x48, 0x03, 0x05, 0x00, 0x00, 0x00, 0x00,
        0x48, 0x83, 0xc0, 0x10,
        0x48, 0x83, 0x45, 0xf0, 0xf0,
        0x80, 0x55, 0xf0, 0x10,
        0x48, 0x83, 0x60, 0x10, 0x08,
        0x48, 0x83, 0x4d, 0x10, 0x0f,
        0x49, 0x83, 0xdb, 0x08,
        0x49, 0x83, 0xec, 0x00,
        0x41, 0x80, 0x73, 0xf0, 0x20,
        0x34, 0x10,
        0x1d, 0x00, 0x00, 0x00, 0x00,
        0x48, 0x2d, 0x0f, 0x00, 0x00, 0x00,
        0x66, 0x1d, 0x00, 0x10,
        0x66, 0x25, 0xf0, 0xff,
        0x66, 0x48, 0x25, 0xf0, 0xff, 0xff, 0xff,
        0x65, 0x66, 0xa1, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x36, 0xa2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x26, 0xa3, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x48, 0xa1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x65, 0x44, 0x01, 0x24, 0x25, 0x00, 0x00, 0x00, 0x10,
        0x0f, 0x05,
        0x42, 0xff, 0x14, 0x5d, 0x00, 0x00, 0x00, 0x00,
        0x42, 0xff, 0x14, 0x65, 0x00, 0x00, 0x00, 0x00,
        0x0f, 0xbf, 0xc3,
        0x0f, 0xbe, 0xc3,
        0x66, 0x0f, 0xbe, 0xc3,
        0x48, 0x63, 0xc3,
        0xe8, 0x00, 0x00, 0x00, 0x00,
        0xe9, 0x00, 0x00, 0x00, 0x00,
        0x41, 0x53,
        0x0f, 0x82, 0x00, 0x00, 0x00, 0x00,
        0x48, 0xD1, 0xE0,
        0x48, 0xC1, 0xE0, 0x3F,
        0x48, 0xC1, 0xE0, 0x3F,
        0x48, 0xC1, 0xF8, 0x3F,
        0x48, 0xC1, 0xE8, 0x3F,
        0x44, 0x84, 0x65, 0xF0,
        0x46, 0x6B, 0x64, 0x5D, 0xF0, 0x08,
        0x41, 0xD3, 0xEC,
        0x4A, 0x0F, 0x4A, 0x44, 0xE5, 0x00,
        0x48, 0x98,
        0x41, 0x84, 0x24, 0x24,
        0x84, 0x65, 0x00,
        // zig fmt: on
    });

    var buf = std.ArrayList(u8).init(gpa);
    defer buf.deinit();

    while (try disassembler.next()) |inst| {
        try inst.fmtPrint(buf.writer());
        try buf.append('\n');
    }

    try testing.expectEqualStrings(
        \\mov rax, 0x10
        \\mov r12d, -0x10
        \\mov r12, rax
        \\mov qword ptr [rip - 0x10], r12
        \\mov qword ptr [rip - 0x10], r11
        \\mov qword ptr [r11 - 0x10], rax
        \\mov byte ptr [rbp + r12 * 8 - 0x10], r11b
        \\mov r12, qword ptr [rbp - 0x10]
        \\mov rax, qword ptr [rbp - 0x1000]
        \\mov rbx, qword ptr [rax]
        \\mov byte ptr [rbp - 0x10], 0x10
        \\mov qword ptr [r11 - 0x10], 0x10
        \\lea rax, qword ptr [rbp - 0x10]
        \\lea eax, dword ptr [r11 + 0x10]
        \\lea r12, qword ptr [rip]
        \\add rax, qword ptr [rip]
        \\add rax, 0x10
        \\add qword ptr [rbp - 0x10], -0x10
        \\adc byte ptr [rbp - 0x10], 0x10
        \\and qword ptr [rax + 0x10], 0x8
        \\or qword ptr [rbp + 0x10], 0xf
        \\sbb r11, 0x8
        \\sub r12, 0x0
        \\xor byte ptr [r11 - 0x10], 0x20
        \\xor al, 0x10
        \\sbb eax, 0x0
        \\sub rax, 0xf
        \\sbb ax, 0x1000
        \\and ax, -0x10
        \\and rax, -0x10
        \\mov ax, gs:0x10
        \\mov ss:0x0, al
        \\mov es:0x8, eax
        \\mov rax, ds:0x0
        \\add dword ptr gs:0x10000000, r12d
        \\syscall
        \\call qword ptr [r11 * 2]
        \\call qword ptr [r12 * 2]
        \\movsx eax, bx
        \\movsx eax, bl
        \\movsx ax, bl
        \\movsxd rax, ebx
        \\call 0x0
        \\jmp 0x0
        \\push r11
        \\jb 0x0
        \\sal rax, 0x1
        \\sal rax, 0x3f
        \\sal rax, 0x3f
        \\sar rax, 0x3f
        \\shr rax, 0x3f
        \\test byte ptr [rbp - 0x10], r12b
        \\imul r12d, dword ptr [rbp + r11 * 2 - 0x10], 0x8
        \\shr r12d, cl
        \\cmovp rax, qword ptr [rbp + r12 * 8]
        \\cdqe
        \\test byte ptr [r12], spl
        \\test byte ptr [rbp], ah
        \\
    , buf.items);
}

// zig fmt: on
