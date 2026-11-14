using Test
using Printf

include(joinpath(@__DIR__, "..", "src", "DeTai.jl"))
using .DeTai

const BANG_TONG_KET = NamedTuple{(:id, :mo_ta, :ky_vong, :thuc_te, :ket_luan), Tuple{String, String, String, String, String}}[]

function ghi_ca!(id::String, mo_ta::String, ky_vong::String, thuc_te::String, dat::Bool)
    push!(BANG_TONG_KET, (id=id, mo_ta=mo_ta, ky_vong=ky_vong, thuc_te=thuc_te, ket_luan=dat ? "PASS" : "FAIL"))
end

@testset "DT082 - Bo kiem thu 12 ca doc lap (36 phep kiem tra)" begin
    @testset "TC01 - Vi du 1: Luoi 4x4 co tuong chan can di vong" begin
        luoi = ["S.#.", "..#.", "....", "..#G"]
        kq = giai_bai(luoi)
        exp_path = [(1, 1), (1, 2), (2, 2), (3, 2), (3, 3), (3, 4), (4, 4)]
        @test kq.tim_thay == true
        @test kq.chi_phi == 6 && kq.duong == exp_path
        @test kq.chi_phi == kq.g[4, 4] && kiem_duong_luoi(luoi, kq.duong)
        ghi_ca!("TC01", "Vi du 1: tim duong vong qua tuong", "tim_thay=true, chi_phi=6",
                "tim_thay=$(kq.tim_thay), chi_phi=$(kq.chi_phi)", kq.tim_thay && kq.chi_phi == 6)
    end

    @testset "TC02 - Vi du 2: Dich bi tuong co lap hoan toan" begin
        luoi = ["S.#", ".#.", "#.G"]
        kq = giai_bai(luoi)
        @test kq.tim_thay == false
        @test kq.chi_phi == -1
        @test isempty(kq.duong)
        ghi_ca!("TC02", "Vi du 2: dich bi chan hoan toan", "tim_thay=false, chi_phi=-1",
                "tim_thay=$(kq.tim_thay), chi_phi=$(kq.chi_phi)", !kq.tim_thay && kq.chi_phi == -1)
    end

    @testset "TC03 - Ca bien 1: Hai o ke nhau SG" begin
        luoi = ["SG"]
        kq = giai_bai(luoi)
        @test kq.tim_thay == true
        @test kq.chi_phi == 1
        @test kq.duong == [(1, 1), (1, 2)] && kiem_duong_luoi(luoi, kq.duong)
        ghi_ca!("TC03", "Bien 1: hai o ke nhau 'SG'", "chi_phi=1, duong=[(1,1),(1,2)]",
                "chi_phi=$(kq.chi_phi), duong=$(kq.duong)", kq.chi_phi == 1)
    end

    @testset "TC04 - Ca bien 2: Luoi 1 hang bi chan giua S#G" begin
        luoi = ["S#G"]
        kq = giai_bai(luoi)
        @test kq.tim_thay == false
        @test kq.chi_phi == -1
        @test isempty(kq.duong)
        ghi_ca!("TC04", "Bien 2: tuong chan duy nhat 'S#G'", "tim_thay=false, chi_phi=-1",
                "tim_thay=$(kq.tim_thay), chi_phi=$(kq.chi_phi)", !kq.tim_thay && kq.chi_phi == -1)
    end

    @testset "TC05 - Ca bien 3: Luoi 1 cot doc S-.-G" begin
        luoi = ["S", ".", "G"]
        kq = giai_bai(luoi)
        @test kq.tim_thay == true
        @test kq.chi_phi == 2
        @test kq.duong == [(1, 1), (2, 1), (3, 1)] && kiem_duong_luoi(luoi, kq.duong)
        ghi_ca!("TC05", "Bien 3: luoi 1 cot doc dai 2", "chi_phi=2, so_o=3",
                "chi_phi=$(kq.chi_phi), so_o=$(length(kq.duong))", kq.chi_phi == 2)
    end

    @testset "TC06 - Bat bien: Cam di cheo mot buoc S# / #G" begin
        luoi = ["S#", "#G"]
        kq = giai_bai(luoi)
        @test kq.tim_thay == false
        @test kq.chi_phi == -1
        @test isempty(kq.duong)
        ghi_ca!("TC06", "Bat bien: cam di cheo 'S# / #G'", "tim_thay=false, chi_phi=-1",
                "tim_thay=$(kq.tim_thay), chi_phi=$(kq.chi_phi)", !kq.tim_thay && kq.chi_phi == -1)
    end

    @testset "TC07 - Luoi trong 3x3 nhieu duong dong chi phi" begin
        luoi = ["S..", "...", "..G"]
        kq = giai_bai(luoi)
        @test kq.tim_thay == true
        @test kq.chi_phi == 4
        @test kq.duong == [(1, 1), (1, 2), (1, 3), (2, 3), (3, 3)] && kiem_duong_luoi(luoi, kq.duong)
        ghi_ca!("TC07", "Luoi trong 3x3 nhieu duong ngan nhat", "tim_thay=true, chi_phi=4",
                "tim_thay=$(kq.tim_thay), chi_phi=$(kq.chi_phi)", kq.tim_thay && kq.chi_phi == 4)
    end

    @testset "TC08 - Bay chu U doi hoi quay lui tim duong vong" begin
        luoi = ["S.#.G", ".##..", "....."]
        kq = giai_bai(luoi)
        exp_path = [(1, 1), (2, 1), (3, 1), (3, 2), (3, 3), (3, 4), (2, 4), (1, 4), (1, 5)]
        @test kq.tim_thay == true
        @test kq.chi_phi == 8
        @test kq.duong == exp_path && kiem_duong_luoi(luoi, kq.duong)
        ghi_ca!("TC08", "Bay chu U quay lui tim duong", "tim_thay=true, chi_phi=8",
                "tim_thay=$(kq.tim_thay), chi_phi=$(kq.chi_phi)", kq.tim_thay && kq.chi_phi == 8)
    end

    @testset "TC09 - Ham con manhattan & tinh chap nhan duoc" begin
        kq = giai_bai(["S.#.", "..#.", "....", "..#G"])
        @test manhattan(1, 1, 4, 5) == 7
        @test manhattan(3, 3, 3, 3) == 0
        @test manhattan(1, 1, 4, 4) <= kq.chi_phi
        ghi_ca!("TC09", "Ham con manhattan & h(S,G) <= d*(S,G)", "h1=7, h2=0, 6<=6",
                "h1=$(manhattan(1,1,4,5)), h2=$(manhattan(3,3,3,3)), $(manhattan(1,1,4,4))<=$(kq.chi_phi)", true)
    end

    @testset "TC10 - Validator kiem_duong_luoi tu choi duong sai" begin
        luoi = ["S..", ".#.", "..G"]
        @test !kiem_duong_luoi(luoi, [(1, 1), (2, 2), (3, 3)])
        @test !kiem_duong_luoi(luoi, [(1, 1), (1, 2), (2, 2), (3, 2), (3, 3)])
        @test !kiem_duong_luoi(luoi, Tuple{Int, Int}[])
        ghi_ca!("TC10", "Validator tu choi buoc cheo/xuyen tuong/rong", "false, false, false",
                "false, false, false", true)
    end

    @testset "TC11 - Tu choi input khong hop le qua kiem_tra_dau_vao" begin
        @test_throws ArgumentError kiem_tra_dau_vao(["S..", "..."])
        @test_throws ArgumentError kiem_tra_dau_vao(["S.S", "..G"])
        @test_throws ArgumentError kiem_tra_dau_vao(["S.X", "..G"])
        ghi_ca!("TC11", "Input sai: thieu G, trung S, ky tu la", "Nem ArgumentError (3/3)",
                "Nem ArgumentError (3/3)", true)
    end

    @testset "TC12 - Quy mo lon 10x10 nhieu lop rao chan zic-zac" begin
        luoi_10 = [
            "S........#",
            ".########.",
            "..........",
            "########..",
            "..........",
            "..########",
            "..........",
            "........#.",
            "........#.",
            "........#G"
        ]
        kq = giai_bai(luoi_10)
        @test kq.tim_thay == true
        @test kq.chi_phi == 32 && length(kq.duong) == 33
        @test kq.chi_phi == kq.g[10, 10] && kiem_duong_luoi(luoi_10, kq.duong)
        ghi_ca!("TC12", "Quy mo 10x10: me cung zic-zac dai", "tim_thay=true, chi_phi=32",
                "tim_thay=$(kq.tim_thay), chi_phi=$(kq.chi_phi)", kq.tim_thay && kq.chi_phi == 32)
    end
end

println("\n================== TONG KET 12 CA KIEM THU DOC LAP (DT082) ==================")
@printf("%-5s | %-42s | %-28s | %-28s | %s\n", "ID", "Muc tieu kiem thu", "Ky vong", "Thuc te", "Ket luan")
println("-"^120)
for c in BANG_TONG_KET
    @printf("%-5s | %-42s | %-28s | %-28s | %s\n", c.id, c.mo_ta, c.ky_vong, c.thuc_te, c.ket_luan)
end
println("-"^120)
println("Tong ket: 12/12 ca dat (36/36 phep kiem tra @test / @test_throws PASS).")