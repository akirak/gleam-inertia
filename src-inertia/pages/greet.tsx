import React from "react";
import Layout from "../components/Layout";
import { Head } from "@inertiajs/react";
import styles from "./page.module.css";

type GreetProps = {
  name: string;
};

export default function Greet({ name }: GreetProps) {
  return (
    <Layout>
      <Head title="Greet" />
      <section className={styles.stack}>
        <h1 className={styles.title}>Hey there, {name}!</h1>
      </section>
    </Layout>
  );
}
