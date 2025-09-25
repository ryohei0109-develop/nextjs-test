type Params = {
  params: Promise<{
    id: string
  }>
};

export default async function BlogPage({params}: Params) {
  console.log(params);
  const { id } = await params;
  return (
    <div>
      ブログID: { id }
    </div>
  );
}
