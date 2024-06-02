mod tests;
use dep::std;
use dep::ecrecover;

global MERKLE_DEPTH = 7;
fn main(
    signer_pub_x_key: [u8; 32],
    signer_pub_y_key: [u8; 32],
    signature: [u8; 64],
    selected_players_points: [[u8; 32]; 11],
    player_points_merkle_paths: [[[u8; 32]; MERKLE_DEPTH]; 11],
    all_player_points_merkle_root: [u8; 32],
    captain: pub u8,
    vice_captain: pub u8,
    is_random: pub bool,
    selected_player_ids: pub [u8; 11],
    selected_squad_hash: pub [u8; 32],
    claimed_player_points: pub u64
) {
    ecdsa_verification(
        signer_pub_x_key,
        signer_pub_y_key,
        signature,
        selected_squad_hash
    );

    verify_squad_hash(selected_player_ids, selected_squad_hash);

    verify_all_merkle_roots(
        selected_player_ids,
        selected_players_points,
        player_points_merkle_paths,
        all_player_points_merkle_root
    );

    calculate_points(
        selected_players_points,
        claimed_player_points,
        captain,
        vice_captain,
        is_random
    );
}

fn verify_squad_hash(player_ids: [u8; 11], squad_hash: [u8; 32]) {
    let computed_squad_hash= std::hash::keccak256(player_ids, 11);
    assert(computed_squad_hash == squad_hash);
}

fn ecdsa_verification(
    signer_pub_x_key: [u8; 32],
    signer_pub_y_key: [u8; 32],
    signature: [u8; 64],
    hash: [u8; 32]
) {
    let computedAddress: Field = ecrecover::secp256k1::PubKey::from_xy(signer_pub_x_key, signer_pub_y_key).to_eth_address(); // Compute address from public key
    let recoveredAddress = ecrecover::ecrecover(signer_pub_x_key, signer_pub_y_key, signature, hash);

    assert(computedAddress == recoveredAddress);
}

fn verify_all_merkle_roots(
    player_ids: [u8; 11],
    players_points: [[u8; 32]; 11],
    merkle_paths: [[[u8; 32]; MERKLE_DEPTH]; 11],
    merkle_root: [u8; 32]
) {
    for i in 0..11 {
        compute_and_verify_merkle_root(players_points[i], player_ids[i], merkle_paths[i], merkle_root);
    }
}

fn compute_and_verify_merkle_root(
    leaf: [u8; 32],
    leaf_index: u8,
    proof: [[u8; 32]; MERKLE_DEPTH],
    all_points_merkle_root: [u8; 32]
) {
    let mut computed_merkle_root: [u8; 32] = [0; 32];
    computed_merkle_root=leaf;
    let mut leaf_index_mut= leaf_index;
    for i in 0..MERKLE_DEPTH {
        if leaf_index_mut % 2 == 0 {
            computed_merkle_root = std::hash::keccak256(concatenate_leafs(computed_merkle_root, proof[i]), 64);
        } else {
            computed_merkle_root = std::hash::keccak256(concatenate_leafs(proof[i], computed_merkle_root), 64);
        }
        leaf_index_mut = leaf_index_mut / 2;
    }

    assert(computed_merkle_root == all_points_merkle_root);
}

fn concatenate_leafs(leaf1: [u8; 32], leaf2: [u8; 32]) -> [u8; 64] {
    let mut arr: [u8; 64] = [0; 64];
    for i in 0..32 {
        arr[i] = leaf1[i];
        arr[i + 32] = leaf2[i];
    }
    arr
}

fn calculate_points(
    player_points: [[u8; 32]; 11],
    claimed_player_points: u64,
    captain: u8,
    vice_captain: u8,
    is_random: bool
) {
    let mut calculated_total_points: u64 = 0;
    let mut counter: u8 = 0;
    let mut captainMultiplier: u64 = 0;
    let mut vice_captainMultiplier: u64 = 0;

    if is_random {
        captainMultiplier = 4;
        vice_captainMultiplier = 3;
    } else {
        captainMultiplier = 3;
        vice_captainMultiplier = 2;
    }

    for point in player_points {
        let mut player_point: u64 = 0;
        for byte in point {
            player_point += byte as u64;
        }
        if counter == captain {
            player_point = player_point * captainMultiplier;
        } else if counter == vice_captain {
            player_point = player_point * vice_captainMultiplier;
        }
        calculated_total_points += player_point;
        counter += 1;
    }

    assert(calculated_total_points == claimed_player_points);
}
