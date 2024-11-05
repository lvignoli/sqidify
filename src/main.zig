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

    // Get standard input and read a single line up to 4kb (should be enough).
    const stdin = std.io.getStdIn().reader();
    var buffer: []const u8 = (try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 1 << 12)).?;
    defer allocator.free(buffer);
    buffer = mem.trim(u8, buffer, &.{' '});

    // Bail out early on zero-length input.
    if (buffer.len == 0) {
        std.log.err("zero-length input", .{});
        return;
    }

    // Parse each space-separated string as a u64 number.
    var it = mem.splitScalar(u8, buffer, ' ');
    var arr = std.ArrayList(u64).init(allocator);
    defer arr.deinit();
    while (it.next()) |tok| {
        const n = std.fmt.parseInt(u64, tok, 10) catch |err| switch (err) {
            error.InvalidCharacter => {
                std.log.err("parsing to u64 integer: invalid character in string: {s}", .{tok});
                return;
            },
            else => return err,
        };
        try arr.append(n);
    }
    const numbers = try arr.toOwnedSlice();
    defer allocator.free(numbers);

    // Using the default Sqids, encode the numbers to a Sqids ID.
    const s = try Sqids.init(allocator, .{});
    defer s.deinit();
    const id = try s.encode(numbers);
    defer allocator.free(id);

    // Print to stdout.
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}\n", .{id});
}
