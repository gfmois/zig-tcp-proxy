const std = @import("std");
const utils = @import("utils.zig");
const Config = @import("config.zig");
const ParseError = @import("errors.zig").ParseError;

pub fn parseArgs(args_z: []const [:0]u8) ParseError!Config {
    var cfg: Config = .{};

    var i: usize = 1;
    while (i < args_z.len) : (i += 1) {
        try parseOne(args_z, &i, &cfg);
    }

    return cfg;
}

fn parseOne(args_z: []const [:0]u8, i: *usize, cfg: *Config) ParseError!void {
    const arg = std.mem.sliceTo(args_z[i.*], 0);
    if (arg.len == 0) return;

    // Simple flags
    if (std.mem.eql(u8, arg, "--help")) {
        cfg.*.help = true;
        return;
    }
    if (std.mem.eql(u8, arg, "--no-stdout")) {
        cfg.*.no_stdout = true;
        return;
    }
    if (std.mem.eql(u8, arg, "--timestamps")) {
        cfg.*.timestamps = true;
        return;
    }

    // --key=value
    if (utils.startsWithEq(arg, "--listen=")) {
        const v = arg["--listen=".len..];
        const p = std.fmt.parseInt(u16, v, 10) catch return error.InvalidValue;
        if (p == 0) return error.InvalidValue;
        cfg.*.listen = p;
        return;
    }
    if (utils.startsWithEq(arg, "--target=")) {
        cfg.*.target = arg["--target=".len..];
        return;
    }
    if (utils.startsWithEq(arg, "--dump-dir=")) {
        cfg.*.dump_dir = arg["--dump-dir=".len..];
        return;
    }
    if (utils.startsWithEq(arg, "--buf=")) {
        const v = arg["--buf=".len..];
        cfg.*.buf = std.fmt.parseInt(usize, v, 10) catch return error.InvalidValue;
        return;
    }

    // --key value
    if (std.mem.eql(u8, arg, "--listen")) {
        const v = try consumeValue(args_z, i);
        const p = std.fmt.parseInt(u16, v, 10) catch return error.InvalidValue;
        if (p == 0) return error.InvalidValue;
        cfg.*.listen = p;
        return;
    }
    if (std.mem.eql(u8, arg, "--target")) {
        cfg.*.target = try consumeValue(args_z, i);
        return;
    }
    if (std.mem.eql(u8, arg, "--dump-dir")) {
        cfg.*.dump_dir = try consumeValue(args_z, i);
        return;
    }
    if (std.mem.eql(u8, arg, "--buf")) {
        const v = try consumeValue(args_z, i);
        cfg.*.buf = std.fmt.parseInt(usize, v, 10) catch return error.InvalidValue;
        return;
    }

    return error.InvalidArgument;
}

fn consumeValue(args_z: []const [:0]u8, i: *usize) ParseError![]const u8 {
    i.* += 1;
    if (i.* >= args_z.len) return error.MissingValue;
    return std.mem.sliceTo(args_z[i.*], 0);
}
