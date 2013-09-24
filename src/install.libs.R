mac = length(grep("mac", .Platform$pkgType)) > 0
if(mac){
	dest <- file.path(R_PACKAGE_DIR,"bin/mac")
	source.file1 <- "excursions"
	source.file2 <- "gaussint"
} else if((.Platform$OS.type == "unix") && !mac){
	dest <- file.path(R_PACKAGE_DIR,"bin/linux")
	source.file1 <- "excursions"
	source.file2 <- "gaussint"
} else if(.Platform$OS.type == "windows") {
	dest <- file.path(R_PACKAGE_DIR,"bin/windows")
	source.file1 <- "excursions.exe"
	source.file2 <- "gaussint.exe"
}else {
	stop("OS not supported")
}
dir.create(dest,recursive=TRUE,showWarnings=FALSE)

file.copy(source.file1,dest,overwrite=TRUE) 
file.copy(source.file2,dest,overwrite=TRUE) 




