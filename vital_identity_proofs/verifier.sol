// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

pragma solidity ^0.4.14;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point) {
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point p) pure internal returns (G1Point) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return the sum of two points of G1
    function addition(G1Point p1, G1Point p2) internal returns (G1Point r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 6, 0, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }
    /// @return the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point p, uint s) internal returns (G1Point r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 7, 0, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] p1, G2Point[] p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point a1, G2Point a2, G1Point b1, G2Point b2) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point a1, G2Point a2,
            G1Point b1, G2Point b2,
            G1Point c1, G2Point c2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point a1, G2Point a2,
            G1Point b1, G2Point b2,
            G1Point c1, G2Point c2,
            G1Point d1, G2Point d2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G2Point A;
        Pairing.G1Point B;
        Pairing.G2Point C;
        Pairing.G2Point gamma;
        Pairing.G1Point gammaBeta1;
        Pairing.G2Point gammaBeta2;
        Pairing.G2Point Z;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G1Point A_p;
        Pairing.G2Point B;
        Pairing.G1Point B_p;
        Pairing.G1Point C;
        Pairing.G1Point C_p;
        Pairing.G1Point K;
        Pairing.G1Point H;
    }
    function verifyingKey() pure internal returns (VerifyingKey vk) {
        vk.A = Pairing.G2Point([0x17555ad422666af12fce351a73f05c4a99c8a5dfd7949903f0d6955167fe023b, 0x13c59d2e1c530d991f4252b0759b6b2dfc54fd8f94bde4ff45ad51a5ad85b64c], [0x2e231be4caf74e84cc2e0e526f056fad2f9c4a5fef006a4d5d447aaafcb86193, 0x2a40fda6b9d4d84dd11d6a46460b6732497223de361add533c187c91855a7560]);
        vk.B = Pairing.G1Point(0x79241f3e60a6a1b0e6fc4ec209aa4a2b0513ddb3d03389a0187816ec7b7fe22, 0x15e0fc22b85bb9386b5e0181be3507f1dd357b19e52fdc51e9d7d54a11aff3a0);
        vk.C = Pairing.G2Point([0x1b242167c026d8ebfd83b3ebcbc25b417b6562770ae156a6dde7d3ecfe6a9f5d, 0x1d8f2f555e9ffb31a37a77a74c1e7ee3ac15d1c9fbe978d892afce6c06086fa3], [0x1889f041665930fa365e5140a3f133b435fa5961a247d5de4ccb2e9d4164bf8a, 0x1b1a03d5bf9843702ac45142f8ea1dc0a99f4edea580048f861ba8f3a4f27fc4]);
        vk.gamma = Pairing.G2Point([0x22db6cf1ee09dff02c9d064b192c89aa4238ebfaa1cf69ef650659d81b8a4abf, 0x286c830aa25a06310c622a57663f9c4bb44421cb91abbf795edba90251ae22e9], [0x2d8a20031a7b306621db5c24541455a96d060429da38fbdebbddd230929e0107, 0x5468e5dc07da6f8d37fd40346809d6d64ce3ca708462786b626644dba63cac3]);
        vk.gammaBeta1 = Pairing.G1Point(0x1dab45a6d52d7325ea49565bfbca6617a358e08629ea6e680500ecf0cf31ef71, 0x1f8866b1def0eb25b47548ccaf43210ceb8d624901297b0edf858d09ea28150d);
        vk.gammaBeta2 = Pairing.G2Point([0x14f1c36e111262e6e50ffd52f3f01200f29b2b2f642b1c785baefed8a138a7d6, 0x19e13807e9bc1ef6abc16c053dc8664c0fb1c457b636311c7bfb49a14f2ea95d], [0x7452aca847c1c876450f11d4cf3cf9c5fb186a966703ec20db85beb07a80cf5, 0x35a5313652359bcffabe48f4ba9a087cdf24e644fc157442bdeb5275d92d3ff]);
        vk.Z = Pairing.G2Point([0x1c13584c652b3988ce17acd9732c9d9b840d0b7a7e5a155de8d29f78c194f19e, 0x751da7787a45d64bdc423e5493bb370ea80cf5a4e26c39f892704291f81321e], [0x167675f114d3956ef743dad6543903c571579f5a19b922aa6038dbc198568ec0, 0x184de8ebfbb4c750db272ae128091370621a19cc40b8cd37d4a8e225fd87c82e]);
        vk.IC = new Pairing.G1Point[](5);
        vk.IC[0] = Pairing.G1Point(0x30117266457783830c3aa1bbcf34d778a3a600c51549e2b9432a7ed2f6abbb17, 0x1cbdbed2433f022674ad20b9f9164405c33c99257630636c8289b4e64624517d);
        vk.IC[1] = Pairing.G1Point(0x20bc68b8fb455d57a6491b422dd7fafd4cd158428a4f8b9875520f7f372ccc5a, 0x25f6be37afe37eff80206f49540cf40d82242f36bd6db8868f88b2f00f198bfd);
        vk.IC[2] = Pairing.G1Point(0xd45c60f7c0295d33d14a4676225170298f1f228a0889f18b23f7f8927913810, 0x2dc24a28e5c23c82b78130b3e86cfb2939ed183827c729e89a230639d7217b41);
        vk.IC[3] = Pairing.G1Point(0x198ab1c84e0928d5f608c8b8b9c316d90bee6e4d226a4d7affb409d22605d295, 0xcbbfd8cde332e2b0befd73a002d83dd6ec26027d0f9c6f05be4bc16ac134dc2);
        vk.IC[4] = Pairing.G1Point(0x8dd4f45c3d2fdf7412948cbce2a8e2dfc6d01916b9670ec8674a7be1987ff41, 0x13f00d467ce366a6daf8822dc7c8fd5fd9cd8b607bd6d2ec5aa66420b4242a6c);
    }
    function verify(uint[] input, Proof proof) internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd2(proof.A, vk.A, Pairing.negate(proof.A_p), Pairing.P2())) return 1;
        if (!Pairing.pairingProd2(vk.B, proof.B, Pairing.negate(proof.B_p), Pairing.P2())) return 2;
        if (!Pairing.pairingProd2(proof.C, vk.C, Pairing.negate(proof.C_p), Pairing.P2())) return 3;
        if (!Pairing.pairingProd3(
            proof.K, vk.gamma,
            Pairing.negate(Pairing.addition(vk_x, Pairing.addition(proof.A, proof.C))), vk.gammaBeta2,
            Pairing.negate(vk.gammaBeta1), proof.B
        )) return 4;
        if (!Pairing.pairingProd3(
                Pairing.addition(vk_x, proof.A), proof.B,
                Pairing.negate(proof.H), vk.Z,
                Pairing.negate(proof.C), Pairing.P2()
        )) return 5;
        return 0;
    }
    event Verified(string s);
    function verifyTx(
            uint[2] a,
            uint[2] a_p,
            uint[2][2] b,
            uint[2] b_p,
            uint[2] c,
            uint[2] c_p,
            uint[2] h,
            uint[2] k,
            uint[4] input
        ) public returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.A_p = Pairing.G1Point(a_p[0], a_p[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.B_p = Pairing.G1Point(b_p[0], b_p[1]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        proof.C_p = Pairing.G1Point(c_p[0], c_p[1]);
        proof.H = Pairing.G1Point(h[0], h[1]);
        proof.K = Pairing.G1Point(k[0], k[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            emit Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}
