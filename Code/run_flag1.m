cd('C:\Users\Jose\OneDrive - Universidad Católica de Chile\Proyecto de tesis\Kohn, D., Leibovici, F., & Tretvoll, H.  (2021)\Replication_KLT_AEJM2020\Code');
s.flag = 1;
try
  run('main.m');
catch e
  fprintf('ERROR: %s
', e.message);
  for k=1:length(e.stack)
    fprintf('  In: %s line %d
', e.stack(k).file, e.stack(k).line);
  end
end
exit;
