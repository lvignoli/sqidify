//! Demo program of using Sqids ID.
//! Usage:
//!     sqidify a b c …
//! where a, b, c, … are u64 numbers.
const std = @import("std");
const mem = std.mem;
const sqids = @import("sqids");
const Sqids = sqids.Sqids;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Get standard input and output
    const stdin = std.io.getStdIn().reader();
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // Read a single line out of the input, up to 1000 characters.
    const max_size = 1000;
    const buffer: []const u8 = try stdin.readUntilDelimiterAlloc(allocator, '\n', max_size);
    defer allocator.free(buffer);

    // Parse each space-separated string as a u64 number.
    var it = mem.splitScalar(u8, buffer, ' ');
    var arr = std.ArrayList(u64).init(allocator);
    defer arr.deinit();
    while (it.next()) |tok| {
        const n = try std.fmt.parseInt(u64, tok, 10);
        try arr.append(n);
    }
    const numbers = try arr.toOwnedSlice();
    defer allocator.free(numbers);

    // Using the default Sqids, encode the numbers to a Sqids ID.
    const s = try Sqids.init(allocator, .{});
    defer s.deinit();
    const id = try s.encode(numbers);
    defer allocator.free(id);

    // Output.
    try stdout.print("{s}\n", .{id});

    // Flush.
    try bw.flush();
}
