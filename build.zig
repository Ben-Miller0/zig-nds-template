const std = @import("std");

pub fn build(b: *std.Build) !void {
    const arm7_elf = b.addExecutable(.{
        .name = "arm7.elf",
        .root_source_file = .{ .path = "src/arm7/arm7.zig" },
        .single_threaded = true,
        .target = b.resolveTargetQuery(.{
            .ofmt = .elf,
            .abi = .eabi,
            .os_tag = .freestanding,
            .cpu_model = std.Target.Query.CpuModel{
                .explicit = &std.Target.arm.cpu.arm7tdmi,
            },
            .cpu_arch = .arm,
        }),
    });
    arm7_elf.setLinkerScript(.{ .path = "src/arm7/linker.ld" });

    b.installArtifact(arm7_elf);
    const arm7_artifact = b.addInstallArtifact(arm7_elf, .{});
    const arm7_step = b.step("arm7", "");
    arm7_step.dependOn(&arm7_artifact.step);

    const arm7_copy = b.addSystemCommand(&.{
        "llvm-objcopy",
        "-O",
        "binary",
        "zig-out/bin/arm7.elf",
        "zig-out/bin/arm7.bin",
    });
    arm7_copy.step.dependOn(arm7_step);

    const arm9_elf = b.addExecutable(.{
        .name = "arm9.elf",
        .root_source_file = .{ .path = "src/arm9/arm9.zig" },
        .single_threaded = true,
        .target = b.resolveTargetQuery(.{
            .ofmt = .elf,
            .abi = .eabi,
            .os_tag = .freestanding,
            .cpu_model = std.Target.Query.CpuModel{
                .explicit = &std.Target.arm.cpu.arm946e_s,
            },
            .cpu_arch = .arm,
        }),
    });

    arm9_elf.setLinkerScript(.{ .path = "src/arm9/linker.ld" });

    b.installArtifact(arm9_elf);
    const arm9_artifact = b.addInstallArtifact(arm9_elf, .{});
    const arm9_step = b.step("arm9", "");
    arm9_step.dependOn(&arm9_artifact.step);

    const arm9_copy = b.addSystemCommand(&.{
        "llvm-objcopy",
        "-O",
        "binary",
        "zig-out/bin/arm9.elf",
        "zig-out/bin/arm9.bin",
    });
    arm9_copy.step.dependOn(arm9_step);

    const ndstool = b.addSystemCommand(&.{
        "ndstool",
        "-7",
        "zig-out/bin/arm7.bin",
        "-9",
        "zig-out/bin/arm9.bin",
        "-c",
        "zig-out/cart.nds",
        "-r9",
        "0x02000000",
        "-e9",
        "0x02000000",
        "-r7",
        "0x037F8000",
        "-e7",
        "0x037F8000",
    });

    b.default_step.dependOn(&ndstool.step);
    ndstool.step.dependOn(&arm7_copy.step);
    ndstool.step.dependOn(&arm9_copy.step);

    const desmume = b.addSystemCommand(&.{
        "desmume",
        "zig-out/cart.nds",
    });
    const run_step = b.step("run", "Run the ROM in Desmume");
    run_step.dependOn(&desmume.step);
    desmume.step.dependOn(b.default_step);
}
