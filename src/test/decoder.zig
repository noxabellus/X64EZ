const std = @import("std");
const testing = std.testing;

const decoder = @import("../decoder.zig");
const Disassembler = decoder.Disassembler;

// zig fmt: on

test "disassemble" {
    var disassembler = Disassembler.init(&.{
        // zig fmt: off
        0x40, 0xb7, 0x10,                                           // mov dil, 0x10
        0x49, 0xbc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, // mov r12, 0x1000000000000000
        0xb8, 0x00, 0x00, 0x00, 0x10,                               // mov eax, 0x10000000
        0x48, 0x8b, 0xd8,                                           // mov rbx, rax
        0x4d, 0x8b, 0xdc,                                           // mov r11, r12
        0x49, 0x8b, 0xd4,                                           // mov rdx, r12
        0x4d, 0x89, 0xdc,                                           // mov r12, r11
        0x49, 0x89, 0xd4,                                           // mov r12, rdx
        0x4c, 0x8b, 0x65, 0xf0,                                     // mov r12, QWORD PTR [rbp - 0x10]
        0x48, 0x8b, 0x85, 0x00, 0xf0, 0xff, 0xff,                   // mov rax, QWORD PTR [rbp - 0x1000]
        0x48, 0x8b, 0x1d, 0x00, 0x00, 0x00, 0x00,                   // mov rbx, QWORD PTR [rip]
        0x48, 0x8b, 0x18,                                           // mov rbx, QWORD PTR [rax]
        // zig fmt: on
    });

    {
        const inst = (try disassembler.next()).?;
        try testing.expect(inst.tag == .mov);
        try testing.expect(inst.enc == .oi);
        try testing.expect(inst.data.oi.reg == .bh);
        try testing.expect(inst.data.oi.imm == 0x10);
    }

    {
        const inst = (try disassembler.next()).?;
        try testing.expect(inst.tag == .mov);
        try testing.expect(inst.enc == .oi);
        try testing.expect(inst.data.oi.reg == .r12);
        try testing.expect(inst.data.oi.imm == 0x1000000000000000);
    }

    {
        const inst = (try disassembler.next()).?;
        try testing.expect(inst.tag == .mov);
        try testing.expect(inst.enc == .oi);
        try testing.expect(inst.data.oi.reg == .eax);
        try testing.expect(inst.data.oi.imm == 0x10000000);
    }

    {
        const inst = (try disassembler.next()).?;
        try testing.expect(inst.tag == .mov);
        try testing.expect(inst.enc == .rm);
        try testing.expect(inst.data.rm.reg == .rbx);
        try testing.expect(inst.data.rm.reg_or_mem.reg == .rax);
    }

    {
        const inst = (try disassembler.next()).?;
        try testing.expect(inst.tag == .mov);
        try testing.expect(inst.enc == .rm);
        try testing.expect(inst.data.rm.reg == .r11);
        try testing.expect(inst.data.rm.reg_or_mem.reg == .r12);
    }

    {
        const inst = (try disassembler.next()).?;
        try testing.expect(inst.tag == .mov);
        try testing.expect(inst.enc == .rm);
        try testing.expect(inst.data.rm.reg == .rdx);
        try testing.expect(inst.data.rm.reg_or_mem.reg == .r12);
    }

    {
        const inst = (try disassembler.next()).?;
        try testing.expect(inst.tag == .mov);
        try testing.expect(inst.enc == .mr);
        try testing.expect(inst.data.mr.reg_or_mem.reg == .r12);
        try testing.expect(inst.data.mr.reg == .r11);
    }

    {
        const inst = (try disassembler.next()).?;
        try testing.expect(inst.tag == .mov);
        try testing.expect(inst.enc == .mr);
        try testing.expect(inst.data.mr.reg_or_mem.reg == .r12);
        try testing.expect(inst.data.mr.reg == .rdx);
    }

    {
        const inst = (try disassembler.next()).?;
        try testing.expect(inst.tag == .mov);
        try testing.expect(inst.enc == .rm);
        try testing.expect(inst.data.rm.reg == .r12);
        try testing.expect(inst.data.rm.reg_or_mem.mem.ptr_size == .qword);
        try testing.expect(inst.data.rm.reg_or_mem.mem.scale_index == null);
        try testing.expect(inst.data.rm.reg_or_mem.mem.base.? == .rbp);
        try testing.expect(@intCast(i8, inst.data.rm.reg_or_mem.mem.disp) == -0x10);
    }

    {
        const inst = (try disassembler.next()).?;
        try testing.expect(inst.tag == .mov);
        try testing.expect(inst.enc == .rm);
        try testing.expect(inst.data.rm.reg == .rax);
        try testing.expect(inst.data.rm.reg_or_mem.mem.ptr_size == .qword);
        try testing.expect(inst.data.rm.reg_or_mem.mem.scale_index == null);
        try testing.expect(inst.data.rm.reg_or_mem.mem.base.? == .rbp);
        try testing.expect(inst.data.rm.reg_or_mem.mem.disp == -0x1000);
    }

    {
        const inst = (try disassembler.next()).?;
        try testing.expect(inst.tag == .mov);
        try testing.expect(inst.enc == .rm);
        try testing.expect(inst.data.rm.reg == .rbx);
        try testing.expect(inst.data.rm.reg_or_mem.mem.ptr_size == .qword);
        try testing.expect(inst.data.rm.reg_or_mem.mem.scale_index == null);
        try testing.expect(inst.data.rm.reg_or_mem.mem.base == null);
        try testing.expect(inst.data.rm.reg_or_mem.mem.disp == 0x0);
    }

    {
        const inst = (try disassembler.next()).?;
        try testing.expect(inst.tag == .mov);
        try testing.expect(inst.enc == .rm);
        try testing.expect(inst.data.rm.reg == .rbx);
        try testing.expect(inst.data.rm.reg_or_mem.mem.ptr_size == .qword);
        try testing.expect(inst.data.rm.reg_or_mem.mem.scale_index == null);
        try testing.expect(inst.data.rm.reg_or_mem.mem.base.? == .rax);
        try testing.expect(inst.data.rm.reg_or_mem.mem.disp == 0x0);
    }
}

test "disassemble - mnemonic" {
    const gpa = testing.allocator;
    var disassembler = Disassembler.init(&.{
        // zig fmt: off
        0x48, 0xb8, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x41, 0xbc, 0xf0, 0xff, 0xff, 0xff,
        0x4c, 0x8b, 0x65, 0xf0,
        0x48, 0x8b, 0x85, 0x00, 0xf0, 0xff, 0xff,
        0x48, 0x8b, 0x18,
        0xc6, 0x45, 0xf0, 0x10,
        0x49, 0xc7, 0x43, 0xf0, 0x10, 0x00, 0x00, 0x00,
        0x4C, 0x89, 0x1d, 0xf0, 0xff, 0xff, 0xff,
        0x49, 0x89, 0x43, 0xf0,
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
        0x42, 0xff, 0x14, 0x5d, 0x00, 0x00, 0x00, 0x00,
        0x42, 0xff, 0x14, 0x65, 0x00, 0x00, 0x00, 0x00,
        0x0f, 0xbf, 0xc3,
        0x0f, 0xbe, 0xc3,
        0x66, 0x0f, 0xbe, 0xc3,
        0x48, 0x63, 0xc3,
        0xe8, 0x00, 0x00, 0x00, 0x00,
        // zig fmt: on
    });

    var buf = std.ArrayList(u8).init(gpa);
    defer buf.deinit();

    while (try disassembler.next()) |inst| {
        try inst.fmtPrint(buf.writer());
        try buf.append('\n');
    }

    try testing.expectEqualStrings(
        \\movabs rax, 0x10
        \\mov r12d, 0xfffffff0
        \\mov r12, QWORD PTR [rbp - 0x10]
        \\mov rax, QWORD PTR [rbp - 0x1000]
        \\mov rbx, QWORD PTR [rax]
        \\mov BYTE PTR [rbp - 0x10], 0x10
        \\mov QWORD PTR [r11 - 0x10], 0x10
        \\mov QWORD PTR [rip - 0x10], r11
        \\mov QWORD PTR [r11 - 0x10], rax
        \\lea rax, QWORD PTR [rbp - 0x10]
        \\lea eax, DWORD PTR [r11 + 0x10]
        \\lea r12, QWORD PTR [rip]
        \\add rax, QWORD PTR [rip]
        \\add rax, 0x10
        \\add QWORD PTR [rbp - 0x10], 0xf0
        \\adc BYTE PTR [rbp - 0x10], 0x10
        \\and QWORD PTR [rax + 0x10], 0x8
        \\or QWORD PTR [rbp + 0x10], 0xf
        \\sbb r11, 0x8
        \\sub r12, 0x0
        \\xor BYTE PTR [r11 - 0x10], 0x20
        \\xor al, 0x10
        \\sbb eax, 0x0
        \\sub rax, 0xf
        \\sbb ax, 0x1000
        \\and ax, 0xfff0
        \\and rax, 0xfffffff0
        \\movabs ax, gs:0x10
        \\movabs ss:0x0, al
        \\movabs es:0x8, eax
        \\movabs rax, ds:0x0
        \\add DWORD PTR gs:0x10000000, r12d
        \\call QWORD PTR [r11 * 2]
        \\call QWORD PTR [r12 * 2]
        \\movsx eax, bx
        \\movsx eax, bl
        \\movsx ax, bl
        \\movsxd rax, ebx
        \\call 0x0
        \\
    , buf.items);
}

// zig fmt: on
