const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Get the sqids module from the sqids package defined in build.zig.zon.
    const sqids_dep = b.dependency("sqids", .{});
    const sqids_module = sqids_dep.module("sqids");

    const exe = b.addExecutable(.{
        .name = "encodang",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Make the sqids module available to our executable under the import name "sqids".
    exe.addModule("sqids", sqids_module);

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
