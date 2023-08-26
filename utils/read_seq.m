function sequences = read_seq(seq_file_path)

% check if the file exists
if ~exist(seq_file_path, 'file')
    error('%s is not found!', seq_file_path);
end


% load evaluation sequences
fid = fopen(seq_file_path, 'r');
i = 0;
sequences = cell(100000, 1);
while ~feof(fid)
    i = i + 1;
    sequences{i, 1} = fgetl(fid);
end
sequences(i+1:end) = [];
fclose(fid);

end