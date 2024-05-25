use crate::verify_squad_hash;

#[test]
fn test_works_1() {
    let squad= [1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12];
    let squad_hash= [
        99, 36, 164, 240, 87, 185, 251, 221, 148, 54, 242, 168, 41, 125, 27, 180, 166, 3, 218, 112, 46, 105, 13, 34, 65, 63, 254, 31, 203, 57, 26, 48
    ];
    verify_squad_hash(squad, squad_hash);
}

#[test]
fn test_works_2() {
    let squad= [23, 1, 3, 32, 22, 67, 8, 0, 44, 33, 87];
    let squad_hash= [
        23, 104, 66, 234, 67, 241, 95, 196, 20, 153, 141, 231, 40, 87, 219, 136, 38, 218, 16, 117, 38, 121, 196, 126, 225, 8, 78, 167, 116, 174, 17, 193
    ];
    verify_squad_hash(squad, squad_hash);
}

#[test(should_fail)]
fn test_fails() {
    let squad= [23, 1, 3, 32, 22, 67, 8, 0, 44, 33, 87];
    let squad_hash= [
        64, 218, 150, 223, 213, 19, 176, 127, 39, 19, 198, 32, 222, 102, 59, 22, 221, 142, 52, 223, 180, 33, 215, 46, 170, 163, 109, 213, 140, 124, 20, 142
    ];
    verify_squad_hash(squad, squad_hash);
}

