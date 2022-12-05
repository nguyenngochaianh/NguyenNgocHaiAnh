
-- 1a
select YEAR(getdate())-YEAR(NGSINH) as N'Tuổi' from NHANVIEN where MANV = '001'

if OBJECT_ID('TuoiNV') is not null 
drop function TuoiNV
go 
create function fn_TuoiNV(@MaNV nvarchar(9))
returns int
as
begin
	return(select YEAR(getdate())-YEAR(NGSINH) as N'Tuổi'
	from NHANVIEN where MANV = @MaNV)
end 
print 'Tuoi nhan vien:'+ convert(nvarchar,dbo.fn_TuoiNV('001'))
print 'Tuoi nhan vien:'+ convert(nvarchar,dbo.fn_TuoiNV('003'))

----1b
select Ma_NVien, COUNT(MADA) from PHANCONG
group by Ma_NVien
select COUNT(MADA) from PHANCONG where MA_NVIEN = '005'
if OBJECT_ID('fn_DemDeAnNV') is not null 
drop function fn_DemDeAnNV
go
create function fn_DemDeAnNV(@MaNV varchar(9))
returns int
as
	begin
		return(select COUNT(MADA) 
		from PHANCONG where MA_NVIEN= @MaNV)
	end
print 'So du an nhan vien da lam'+ convert(varchar, dbo.fn_DemDeAnNV('005'))

--1c
select * from NHANVIEN
select COUNT(*) from NHANVIEN where PHAI like 'Nam'
select COUNT(*) from NHANVIEN where PHAI like N'Nữ'

create function fn_DemNV_Phai(@Phai nvarchar(5)=N'%')
returns int
as 
	begin
		return(select COUNT(*) from NHANVIEN where PHAI like @phai)
	end
print 'Nhan vien nam:'+ convert(varchar, fn_DemNV_Phai('Nam'))
print 'Nhan vien nam:'+ convert(varchar, fn_DemNV_Phai(N'Nữ'))
--1d

select PHG, TENPHG, AVG(LUONG) from NHANVIEN inner join PHONGBAN on PHONGBAN.MAPHG = NHANVIEN.PHG
group by PHG, TENPHG
select AVG(LUONG) from NHANVIEN inner join PHONGBAN on PHONGBAN.MAPHG = NHANVIEN.PHG
where TENPHG = 'IT'

if OBJECT_ID('') is not null
	drop function fn_Luong_NhanVien_PB
create function fn_Luong_NhanVien_PB(@TenPhongBan nvarchar(20))
returns @tbLuongNV table(fullname nvarchar(50),luong float)
as 
begin
		declare @LuongTB float
		select @LuongTB = AVG(LUONG) from NHANVIEN
		inner join PHONGBAN on PHONGBAN.MAPHG = NHANVIEN.PHG
		where TENPHG = @TenPhongBan
		insert into @tbLuongNV
			select HONV+ ''+TENLOT+''+TENNV, LUONG from NHANVIEN
			where LUONG > @LuongTB
		return
end

--1e
select TENPHG,TRPHG,HONV+''+TENLOT+ ' ' + TENNV as 'Ten Truong Phog', COUNT(MADA) as 'SoLuongDeAn'
from PHONGBAN inner join DEAN on DEAN.PHONG = PHONGBAN.MAPHG inner join NHANVIEN on NHANVIEN.MANV = PHONGBAN.TRPHG
where PHONGBAN.MAPHG = '001'
group by TENPHG,TRPHG,TENNV,HONV,TENLOT

if OBJECT_ID('fn_SoLuongDeAnTheoPB') is not null
	drop function fn_SoLuongDeAnTheoPB
	go
create function fn_SoLuongDeAnTheoPB(@MaPB int)
returns @tbListPB table(TenPB nvarchar(20),MaTB nvarchar(10), TenTP nvarchar(50), soluong int)
as
begin
	insert into @tbListPB
	select TENPHG,TRPHG,HONV+''+TENLOT+ ' ' + TENNV as 'Ten Truong Phog', COUNT(MADA) as 'SoLuongDeAn'
		from PHONGBAN
		inner join DEAN on DEAN.PHONG = PHONGBAN.MAPHG
		inner join NHANVIEN on NHANVIEN.MANV = PHONGBAN.TRPHG
		where PHONGBAN.MAPHG = @MaPB
		group by TENPHG,TRPHG,TENNV,HONV,TENLOT
	return
end

select * from db.fn_SoLuongDeAnTheoPB(2)
select TENPHG,TRPHG,HONV+''+TENLOT+ ' ' + TENNV as 'Ten Truong Phog', COUNT(MADA) á 'SoLuongDeAn'
from PHONGBAN inner join DEAN on DEAN.PHONG = PHONGBAN.MAPHG inner join NHANVIEN on NHANVIEN.MANV = PHONGBAN.TRPHG
group by TENPHG,TRPHG,TENNV,HONV,TENLOT

-----2a
SELECT HONV, TENNV, TENPHG, DIADIEM from PHONGBAN inner join DIADIEM_PHG on DIADIEM_PHG.MAPHG = PHONGBAN.MAPHG
 inner join NHANVIEN on NHANVIEN.PHG = PHONGBAN.MAPHG 

create view DD_PhongBan
as
select HONV, TENNV, DIADIEM from PHONGBAN inner join DIADIEM_PHG on DIADIEM_PHG.MAPHG = PHONGBAN.MAPHG
inner join NHANVIEN on NHANVIEN.PHG = PHONGBAN.MAPHG 
select * from DD_PhongBan 

----2b
select TENNV,LUONG,YEAR(GETDATE())-YEAR(NGSINH) as 'tuoi'
from NHANVIEN
create view TuoiNhanvien
as
select TENNV,LUONG,YEAR((GETDATE))-YEAR(NGSINH) as 'tuoi'
from NHANVIEN

select * from TuoiNhanvien
----3c
CREATE VIEW PhongBanDonghat
as
select a.TENPHG,b.HONV+' '+b.TENLOT+' '+b.TENNV as 'TenTruongPhong'
from PHONGBAN a inner join NHANVIEN b on a.TRPHG = b.MANV
where a.MAPHG in (select PHG from NHANVIEN
group by phg having count (manv)=(select top 1 count (manv) as NVCount from NHANVIEN
group by phg order by NVCount desc))
select* from PhongBanDongnhat
