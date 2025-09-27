import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "ブログ記事一覧",
  description: "ブログ記事の一覧が表示されます",
};

// ダミーデータ
const articles = [
  {id: '1', title: 'タイトル1'},
  {id: '2', title: 'タイトル2'},
  {id: '3', title: 'タイトル3'}
];

// 1秒待機
async function fetchArticles() {
  await new Promise((resolve) => setTimeout(resolve, 1000));
  // throw new Error('エラーが発生');
  return articles;
}

export default async function BlogListPage() {
  const articles = await fetchArticles();
  return (
    <div>
      <ul>
        {
          articles.map((article) => (
            <li key={article.id}>
              タイトル: {article.title}
            </li>
          ))
        }
      </ul>
    </div>
  );
}
