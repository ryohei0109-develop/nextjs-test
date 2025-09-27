import Image from "next/image"

export default async function SSGPage() {
  const res = await fetch('https://dog.ceo/api/breeds/image/random');
  const resJson = await res.json();
  const imageUrl = resJson.message;
  
  const timestamp = new Date().toISOString();

  return (
    <div>
      SSR ビルド時に生成され固定: { timestamp }
      <Image src={imageUrl} width={400} alt="" />
    </div>
  );
}
