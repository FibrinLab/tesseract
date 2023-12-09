"use client";

import React from "react";
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
import { useState } from "react";



export default function Page() {

  const [data, setData] = useState('');

  return (

    <div className="flex flex-col py-2 h-full container mx-auto pt-24 ">
      <div className="space-y-8 py-10">
        <input
          placeholder="Create post"
          onChange={e => setData(e.target.value)}
        />


        <h3>Testing</h3>

      </div>
    </div>
  );
}
