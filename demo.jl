include(joinpath(@__DIR__, "src", "DeTai.jl"))
using .DeTai

# Dữ liệu chính thay cho `du_lieu = nothing` trong khung bài nộp
const du_lieu = [
    "S.#.",
    "..#.",
    "....",
    "..#G"
]

function chay_minh_hoa(ma::String, mo_ta::String, luoi, ky_vong::String; hien_trace::Bool=false)
    println("==================================================================")
    println("[$ma] $mo_ta")
    println("Input luoi:")
    for hang in luoi
        println("  ", hang)
    end
    println("Ky vong : $ky_vong")

    kq = giai_bai(luoi)
    if kq.tim_thay
        hop_le = kiem_duong_luoi(luoi, kq.duong)
        println("Thuc te : tim_thay=true, chi_phi=$(kq.chi_phi), duong=$(kq.duong)")
        println("Kiem tra duong hop le (validator): $(hop_le ? "DUNG" : "SAI") | So buoc mo rong: $(length(kq.trace))")
    else
        println("Thuc te : tim_thay=false, chi_phi=-1, duong=[] (KHONG CO DUONG)")
        println("So buoc mo rong truoc khi het hang doi: $(length(kq.trace))")
    end

    if hien_trace
        println("\nBang lan vet chi tiet ($ma):")
        in_bang_truy_vet(kq)
    end
    return kq
end

function chay_ca_theo_so(so::Int)
    if so == 1
        chay_minh_hoa("A01", "Vi du 1: Luoi 4x4 co tuong chan can di vong + bang lan vet",
                      du_lieu, "tim_thay=true, chi_phi=6"; hien_trace=true)
    elseif so == 2
        chay_minh_hoa("A02", "Vi du 2: Dich G bi tuong co lap hoan toan (vo nghiem)",
                      ["S.#", ".#.", "#.G"], "tim_thay=false, chi_phi=-1"; hien_trace=true)
    elseif so == 3
        chay_minh_hoa("A03", "Ca bien 1: Hai o xuat phat va dich ke nhau 'SG'",
                      ["SG"], "tim_thay=true, chi_phi=1, duong=[(1, 1), (1, 2)]")
    elseif so == 4
        chay_minh_hoa("A04", "Ca bien 2: Luoi 1 hang bi tuong chan giua 'S#G'",
                      ["S#G"], "tim_thay=false, chi_phi=-1")
    elseif so == 5
        chay_minh_hoa("A05", "Ca bien 3: Luoi 1 cot doc ['S', '.', 'G']",
                      ["S", ".", "G"], "tim_thay=true, chi_phi=2, duong=[(1, 1), (2, 1), (3, 1)]")
    elseif so == 6
        chay_minh_hoa("A06", "Bat bien: Cam di cheo mot buoc tren luoi 2x2 ['S#', '#G']",
                      ["S#", "#G"], "tim_thay=false, chi_phi=-1 (khong duoc di cheo)")
    elseif so == 7
        kq = chay_minh_hoa("A07", "Bay chu U quay lui + kiem tra ham con manhattan & validator",
                           ["S.#.G", ".##..", "....."], "tim_thay=true, chi_phi=8")
        h_sg = manhattan(1, 1, 1, 5)
        sai_cheo = kiem_duong_luoi(["S..", ".#.", "..G"], [(1, 1), (2, 2), (3, 3)])
        println("Ham con manhattan(1,1 -> 1,5) = $h_sg <= chi_phi=$(kq.chi_phi) (chap nhan duoc: DUNG)")
        println("Validator tu choi duong di cheo [(1,1),(2,2),(3,3)]: $(!sai_cheo ? "DUNG" : "SAI")")
    elseif so == 8
        println("==================================================================")
        println("[A08] Kiem tra tu choi du lieu dau vao sai qua kiem_tra_dau_vao")
        luoi_sai = ["S.S", "..G"]
        println("Input   : $luoi_sai (trung 2 diem xuat phat 'S')")
        println("Ky vong : Nem ngoai le ArgumentError va tu choi xu ly")
        try
            giai_bai(luoi_sai)
            error("LOI: Chuong trinh da chap nhan du lieu khong hop le!")
        catch e
            e isa ArgumentError || rethrow()
            println("Thuc te : Da bat dung ArgumentError -> $(sprint(showerror, e))")
        end
    else
        throw(ArgumentError("Chi ho tro --ca=1 den --ca=8"))
    end
end

function nhap_ban_phim()
    println("Nhap so hang R va so cot C (vi du: 4 4):")
    rc = parse.(Int, split(readline()))
    length(rc) == 2 || throw(ArgumentError("Can nhap dung 2 so nguyen R C"))
    R, C = rc
    luoi = String[]
    for r in 1:R
        println("Nhap hang $r (do dai $C, gom '.', '#', 'S', 'G'):")
        push!(luoi, String(strip(readline())))
    end
    chay_minh_hoa("NHAP_TAY", "Du lieu nhap tu ban phim", luoi, "Tim duong ngan nhat theo A*"; hien_trace=true)
end

if "--nhap" in ARGS
    nhap_ban_phim()
elseif any(startswith("--ca="), ARGS)
    ca_str = only(filter(startswith("--ca="), ARGS))
    so = parse(Int, replace(ca_str, "--ca=" => ""))
    chay_ca_theo_so(so)
else
    println("DT082 - A* TIM DUONG TREN LUOI BON HUONG (CHAY DU 8 MUC TIEU A01..A08)")
    for i in 1:8
        chay_ca_theo_so(i)
    end
end