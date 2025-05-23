// フィルタリング機能: 完了済み表示の切り替え
function toggleCompletedDisplay(showCompleted) {
  const currentUrl = new URL(window.location);
  
  if (showCompleted) {
    currentUrl.searchParams.set('show_completed', 'true');
  } else {
    currentUrl.searchParams.delete('show_completed');
  }
  
  window.location.href = currentUrl.toString();
}

// ページ読み込み時の初期化
document.addEventListener('DOMContentLoaded', function() {
  console.log('Todo一覧ページが読み込まれました');
});