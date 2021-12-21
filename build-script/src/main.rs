use quasar::{
    executor::{self, Target},
    assembler::{self,Statement, Assembler},
    context::{LineInfo, ContextStr},
    message::MsgQueue,
    rom::Rom,
    expression::{Expression, Label},
    optimizer,
};

use snesgfx::{color,gfx};

macro_rules! ctx {
    () => {
        ContextStr::new(String::new(), LineInfo::custom(format!("{}:{}:{}", file!(), line!(), column!())))
    }
}
fn main() {
    let mut rom = Rom::new(vec![]);
    let mut target = Target::new(Rom::new(vec![]));
    let mut asm = Assembler::new();
    executor::exec_file("../src/main.asm", ctx!(), &mut target, &mut asm);
    // all of the other funky stuff goes here
    add_segment(0x828000, &mut target, &mut asm);
    add_gfx4("../assets/testgfx.png", "TestGfx", true, &mut target, &mut asm);
    add_gfx4("../assets/sprgfx.png", "SprGfx", true, &mut target, &mut asm);
    add_palette("../assets/testpal.png", "TestPal", &mut target, &mut asm);
    //add_segment(0x838000, &mut target, &mut asm);
    //add_gfx4("../player_gfx.png", "PlayerGfx", false, &mut target, &mut asm);



    MsgQueue::drain(|i| {
        println!("{}", i);
    });
    if MsgQueue::has_error() {
        println!("Parsing failed");
        return;
    }
    asm.resolve_labels();
    // optimizer goes here
    asm.write_to_rom(&mut target, &mut rom);
    MsgQueue::drain(|i| {
        println!("{}", i);
    });
    if MsgQueue::has_error() {
        println!("Assembly failed");
        return;
    }
    rom.resize(256*1024);   // 256kB rom
    rom.fix_checksum();
    let _ = std::fs::create_dir("../out/");
    std::fs::write("../out/visions.sfc", rom.as_slice()).unwrap();
}

pub fn add_segment(offset: u32, target: &mut Target, asm: &mut Assembler) {
    asm.new_segment(ctx!(), assembler::StartKind::Expression(Expression::value(ctx!(), offset as _)), target);
}
pub fn add_palette(file: &str, label: &str, target: &mut Target, asm: &mut Assembler) {
    let mut buf = vec![];
    let file = image::open(file).unwrap().to_rgba8();
    color::Palette::from_image(&file).to_format(snesgfx::color::Snes, &mut buf);
    let stmt = Statement::label(target.label_id(Label::Named {
        stack: vec![label.into()],
        invoke: None
    }, true), ctx!());
    asm.append(stmt, target);
    let stmt = Statement::binary(buf, ctx!());
    asm.append(stmt, target);
}


pub fn add_gfx4(file: &str, label: &str, compressed: bool, target: &mut Target, asm: &mut Assembler) {
    let mut buf = vec![];
    let file = image::open(file).unwrap().to_rgba8();
    gfx::Graphics::from_headered_image(&file).unwrap().to_format(snesgfx::gfx::Snes::<4>, &mut buf);
    if compressed {
        buf = lz4::block::compress(&buf, lz4::block::CompressionMode::HIGHCOMPRESSION(12).into(), false).unwrap();
    }

    let stmt = Statement::label(target.label_id(Label::Named {
        stack: vec![label.into()],
        invoke: None
    }, true), ctx!());
    asm.append(stmt, target);
    let stmt = Statement::binary(buf, ctx!());
    asm.append(stmt, target);
    let stmt = Statement::label(target.label_id(Label::Named {
        stack: vec![format!("{}_end", label)],
        invoke: None
    }, true), ctx!());
    asm.append(stmt, target);
}
