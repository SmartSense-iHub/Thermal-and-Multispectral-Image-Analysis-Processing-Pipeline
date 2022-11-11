function fullFileNames = getFullfilenames(folder_name,bandName,imageFormat)

myDir_sequioa = dir(convertCharsToStrings(folder_name)+'\**\*'+bandName+'*.'+imageFormat);
FilesName = {myDir_sequioa.name}';
FolderName={myDir_sequioa.name}';
fullFileNames = strcat({myDir_sequioa.folder},'\',{myDir_sequioa.name});
fullFileNames=(fullFileNames)';

end 
