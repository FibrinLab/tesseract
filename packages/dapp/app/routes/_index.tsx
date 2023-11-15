import type { MetaFunction } from "@remix-run/node";
import Header from "~/components/Header";

import { useOptionalUser } from "~/utils";

export const meta: MetaFunction = () => [
  { title: "Tesseract | Demystifying Genes" },
  {
    property: "og:title",
    content: "Tesseract | Demystifying Genes",
  },
  {
    name: "description",
    content: "Tesseract | Demystifying Genes",
  }
];

export default function Index() {
  return (
      <div>
        <Header />
      </div>
  );
}
