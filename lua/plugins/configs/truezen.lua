local status, truezen = pcall(require, "true-zen");
if not status then
  vim.notify("True-zen is not installed, skipping...");
  return;
end


