const std = @import("std");
const cli = @import("cli.zig");
const server = @import("server.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args_z = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args_z);

    const cfg = try cli.parseArgs(args_z);
    if (cfg.help) {
        std.debug.print(
            \\Usage:
            \\  tcp-proxy [--help] [--listen <port>] [--target <host>] [--buf <n>] [--dump-dir <path>] [--no-stdout] [--timestamps]
            \\Examples:
            \\  tcp-proxy --listen 8080 --target 127.0.0.1|0.0.0.0:8081 --buf 1024
            \\  tcp-proxy --dump-dir=/tmp --no-stdout
            \\
        , .{});
        return;
    }

    std.debug.print("listen={any}\n", .{cfg.listen});
    std.debug.print("no_stdout={any}\n", .{cfg.no_stdout});
    std.debug.print("timestamps={any}\n", .{cfg.timestamps});
    std.debug.print("target={s}\n", .{cfg.target orelse "(null)"});
    std.debug.print("dump_dir={s}\n", .{cfg.dump_dir orelse "(null)"});

    if (cfg.buf) |b| {
        std.debug.print("buf={d}\n", .{b});
    } else {
        std.debug.print("buf=(null)\n", .{});
    }

    var tcp_server = try server.Server.init(allocator, cfg.listen);
    tcp_server.run() catch |err| {
        std.debug.print("Error while trying to init TCP server: {any}\n", .{@errorName(err)});
    };
}
