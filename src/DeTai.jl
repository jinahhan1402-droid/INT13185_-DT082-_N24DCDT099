module DeTai

using Printf

export kiem_tra_dau_vao, giai_bai, manhattan, truy_vet_luoi, kiem_duong_luoi, in_bang_truy_vet

# Phần tử trong Min-Heap: (f, h, r, c) với f = g + h; ưu tiên f nhỏ nhất, hòa thì h nhỏ nhất
const HeapItem = Tuple{Int, Int, Int, Int}

"""Tính khoảng cách Manhattan h(r1, c1) -> (r2, c2) = |r1 - r2| + |c1 - c2|."""
manhattan(r1::Integer, c1::Integer, r2::Integer, c2::Integer) =
    abs(Int(r1) - Int(r2)) + abs(Int(c1) - Int(c2))

function heap_push!(h::Vector{HeapItem}, item::HeapItem)
    push!(h, item)
    i = length(h)
    while i > 1
        p = i ÷ 2
        if h[i] < h[p]
            h[i], h[p] = h[p], h[i]
            i = p
        else
            break
        end
    end
end

function heap_pop!(h::Vector{HeapItem})
    top = h[1]
    last_item = pop!(h)
    if !isempty(h)
        h[1] = last_item
        i = 1
        n = length(h)
        while true
            l = 2i
            r = 2i + 1
            smallest = i
            if l <= n && h[l] < h[smallest]
                smallest = l
            end
            if r <= n && h[r] < h[smallest]
                smallest = r
            end
            if smallest != i
                h[i], h[smallest] = h[smallest], h[i]
                i = smallest
            else
                break
            end
        end
    end
    return top
end

"""
    kiem_tra_dau_vao(du_lieu)

Kiểm tra hợp đồng đầu vào của lưới ký tự:
- `du_lieu` là mảng chuỗi khác rỗng, kích thước 1 <= R, C <= 100, các hàng dài bằng nhau.
- Chỉ chứa các ký tự hợp lệ: '.' (trống), '#' (tường), 'S' (xuất phát), 'G' (đích).
- Có đúng 1 ô 'S' và đúng 1 ô 'G'.
Trả về `(mat, S, G)`.
"""
function kiem_tra_dau_vao(du_lieu)
    du_lieu isa AbstractVector{<:AbstractString} ||
        throw(ArgumentError("du_lieu phai la mang cac chuoi ky tu"))
    R = length(du_lieu)
    1 <= R <= 100 || throw(ArgumentError("So hang R phai nam trong 1..100"))
    hang_dau = collect(du_lieu[1])
    C = length(hang_dau)
    1 <= C <= 100 || throw(ArgumentError("So cot C phai nam trong 1..100"))

    mat = Matrix{Char}(undef, R, C)
    pos_s = nothing
    pos_g = nothing

    for r in 1:R
        chars = collect(du_lieu[r])
        length(chars) == C || throw(ArgumentError("Cac hang trong luoi phai co cung do dai C"))
        for c in 1:C
            ch = chars[c]
            ch in ('.', '#', 'S', 'G') || throw(ArgumentError("Ky tu khong hop le '$ch' tai ($r, $c)"))
            mat[r, c] = ch
            if ch == 'S'
                pos_s === nothing || throw(ArgumentError("Luoi co nhieu hon mot diem xuat phat 'S'"))
                pos_s = (r, c)
            elseif ch == 'G'
                pos_g === nothing || throw(ArgumentError("Luoi co nhieu hon mot diem dich 'G'"))
                pos_g = (r, c)
            end
        end
    end

    pos_s === nothing && throw(ArgumentError("Luoi thieu diem xuat phat 'S'"))
    pos_g === nothing && throw(ArgumentError("Luoi thieu diem dich 'G'"))
    return mat, pos_s, pos_g
end

"""Lần ngược mảng `cha` từ G về S rồi đảo chiều; trả về mảng rỗng nếu không tới được."""
function truy_vet_luoi(cha::AbstractMatrix{Tuple{Int, Int}}, S::Tuple{Int, Int}, G::Tuple{Int, Int})
    R, C = size(cha)
    (1 <= S[1] <= R && 1 <= S[2] <= C && 1 <= G[1] <= R && 1 <= G[2] <= C) ||
        throw(ArgumentError("Toa do S, G nam ngoai kich thuoc luoi"))
    duong = Tuple{Int, Int}[]
    curr = G
    for _ in 1:(R * C)
        push!(duong, curr)
        if curr == S
            reverse!(duong)
            return duong
        end
        curr = cha[curr[1], curr[2]]
        curr == (0, 0) && return Tuple{Int, Int}[]
        (1 <= curr[1] <= R && 1 <= curr[2] <= C) ||
            throw(ArgumentError("Mang cha chua toa do ngoai mien"))
    end
    throw(ArgumentError("Mang cha co chu trinh"))
end

"""Validator độc lập kiểm tra đường đi hợp lệ trên lưới 4 hướng."""
function kiem_duong_luoi(du_lieu, duong::AbstractVector{<:Tuple{Integer, Integer}})
    mat, S, G = kiem_tra_dau_vao(du_lieu)
    isempty(duong) && return false
    Tuple{Int, Int}(first(duong)) == S || return false
    Tuple{Int, Int}(last(duong)) == G || return false

    R, C = size(mat)
    for (r, c) in duong
        (1 <= r <= R && 1 <= c <= C) || return false
        mat[r, c] != '#' || return false
    end

    for i in 1:(length(duong) - 1)
        r1, c1 = duong[i]
        r2, c2 = duong[i + 1]
        manhattan(r1, c1, r2, c2) == 1 || return false
    end
    return true
end

"""
    giai_bai(du_lieu)

Tìm đường đi ngắn nhất từ 'S' đến 'G' trên lưới 4 hướng bằng thuật toán A*
với heuristic Manhattan. Trả về NamedTuple gồm:
`tim_thay`, `duong`, `chi_phi`, `S`, `G`, `g`, `cha`, `trace`.
"""
function giai_bai(du_lieu)
    mat, S, G = kiem_tra_dau_vao(du_lieu)
    R, C = size(mat)
    INF = typemax(Int) ÷ 4

    g = fill(INF, R, C)
    cha = fill((0, 0), R, C)
    da_dong = falses(R, C)

    sr, sc = S
    gr, gc = G
    g[sr, sc] = 0
    h0 = manhattan(sr, sc, gr, gc)

    pq = HeapItem[]
    heap_push!(pq, (h0, h0, sr, sc))

    trace = NamedTuple{(:buoc, :f, :g, :h, :o, :cha), Tuple{Int, Int, Int, Int, Tuple{Int, Int}, Tuple{Int, Int}}}[]
    buoc = 0
    huong = ((-1, 0), (1, 0), (0, -1), (0, 1)) # Lên, Xuống, Trái, Phải (cấm đi chéo)

    while !isempty(pq)
        f, h, r, c = heap_pop!(pq)
        da_dong[r, c] && continue
        da_dong[r, c] = true

        buoc += 1
        push!(trace, (buoc=buoc, f=f, g=g[r, c], h=h, o=(r, c), cha=cha[r, c]))

        if (r, c) == G
            duong = truy_vet_luoi(cha, S, G)
            chi_phi = g[gr, gc]
            @assert length(duong) - 1 == chi_phi
            @assert kiem_duong_luoi(du_lieu, duong)
            return (; tim_thay=true, duong, chi_phi, S, G, g, cha, trace)
        end

        for (dr, dc) in huong
            nr, nc = r + dr, c + dc
            if 1 <= nr <= R && 1 <= nc <= C && mat[nr, nc] != '#'
                g_moi = g[r, c] + 1
                if g_moi < g[nr, nc]
                    g[nr, nc] = g_moi
                    cha[nr, nc] = (r, c)
                    nh = manhattan(nr, nc, gr, gc)
                    heap_push!(pq, (g_moi + nh, nh, nr, nc))
                end
            end
        end
    end

    return (; tim_thay=false, duong=Tuple{Int, Int}[], chi_phi=-1, S, G, g, cha, trace)
end

"""In bảng lần vết từng bước lấy ô khỏi Min-Heap (phục vụ Bảng 3.3 báo cáo)."""
function in_bang_truy_vet(kq)
    println("Buoc |  f |  g |  h | O lay (r,c) | Cha (r,c)")
    println("-----+----+----+----+-------------+----------")
    for t in kq.trace
        @printf("%4d | %2d | %2d | %2d |   (%2d, %2d)  | (%2d, %2d)\n",
                t.buoc, t.f, t.g, t.h, t.o[1], t.o[2], t.cha[1], t.cha[2])
    end
end

end # module DeTai