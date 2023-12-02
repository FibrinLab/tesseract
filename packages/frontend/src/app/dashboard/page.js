"use client";

import React from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { useHelia } from "@/components/HeliaContext";
import { strings } from "@helia/strings";



const formSchema = z.object({
  username: z.string().min(2, {
    message: "Username must be at least 2 characters.",
  }),
  helix1: z.string(),
  // helix: z.instanceof(File)
});

export default function Page() {
  const { helia, id, isOnline } = useHelia();

  if (!helia || !id) {
    return <h4>Connecting to IPFS...</h4>;
  }

  console.log(helia);

  const s = strings(helia);
  const myImmutableAddress = async () => {
    await s.add("hello world");
    const address = await myImmutableAddress();
    console.log(address);
  };


  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      username: "",
    },
  });

  // function onSubmit(values: z.infer<typeof formSchema>) {
  //   console.log(values);
  // }

  return (
    <div className="flex flex-col py-2 h-full container mx-auto pt-24 ">
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
          <FormField
            control={form.control}
            name="username"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Username</FormLabel>
                <FormControl>
                  <Input placeholder="Satosi Nakomoto" {...field} />
                </FormControl>
                <FormDescription>This is public.</FormDescription>
                <FormMessage />
              </FormItem>
            )}
          />
          {/* 
          <FormField
            control={form.control}
            name="helix1"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Attach Genetic Data</FormLabel>
                <FormControl>
                  <Input type="text" placeholder="https://ipfs.io/ipfs/..." {...field} />
                </FormControl>
                <FormDescription>
                  This will be uploaded to IPFS.
                </FormDescription>
                <FormMessage />
              </FormItem>
            )}
          /> */}

          <div>
            <h4>ID: {id}</h4>
            <h4>Status: {isOnline ? "Online" : "Offline"}</h4>
          </div>

          <Button type="submit">Submit</Button>
        </form>
      </Form>
    </div>
  );
}
