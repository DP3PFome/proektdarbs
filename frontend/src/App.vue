<template>
  <div class="app">
    <!-- Header -->
    <header class="header">
      <h1>Kolekcionāru portāls</h1>
      <button class="login-btn" @click="login">
  {{ isLoggedIn ? 'Iziet' : 'Ienākt' }}
</button>

    </header>
<p v-if="!isLoggedIn" style="color: gray;">
  Lai pievienotu kolekciju, lūdzu ienāciet sistēmā
</p>

    <!-- Main -->
    <main class="container">
      <h2>Manas kolekcijas</h2>

      <form
  v-if="isLoggedIn"
  class="form"
  @submit.prevent="saveCollection"
>

        <input
          v-model="form.title"
          type="text"
          placeholder="Kolekcijas nosaukums"
          required
        />

        <textarea
          v-model="form.description"
          placeholder="Apraksts"
        ></textarea>

        <button type="submit">Saglabāt kolekciju</button>
      </form>

      <ul class="list">
        <li v-for="c in collections" :key="c.id">
          <strong>{{ c.title }}</strong>
          <p>{{ c.description }}</p>
        </li>
      </ul>
    </main>
  </div>
</template>

<script>
import axios from "axios";

export default {
  data() {
    return {
      collections: [],
      form: {
        title: "",
        description: ""
      }
    };
  },
  data() {
  return {
    isLoggedIn: false,
    collections: [],
    form: {
      title: "",
      description: ""
    }
  };
},

  mounted() {
    this.loadCollections();
  },
  methods: {
    async loadCollections() {
      const res = await axios.get("http://127.0.0.1:8000/api/collections");
      this.collections = res.data;
      
    },
    login() {
  this.isLoggedIn = !this.isLoggedIn;
},

    async saveCollection() {
      try {
        await axios.post("http://127.0.0.1:8000/api/collections", this.form);
        this.form.title = "";
        this.form.description = "";
        this.loadCollections();
      } catch (e) {
        alert("Kļūda saglabājot kolekciju");
      }
    }
  }
  
};

</script>

<style>
body {
  margin: 0;
  font-family: Arial, sans-serif;
  background: #f4f6f8;
}

.header {
  background: #1976d2;
  color: white;
  padding: 16px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.login-btn {
  background: white;
  color: #1976d2;
  border: none;
  padding: 8px 16px;
  cursor: pointer;
  border-radius: 4px;
}

.container {
  max-width: 800px;
  margin: 30px auto;
  background: white;
  padding: 24px;
  border-radius: 8px;
}

.form input,
.form textarea {
  width: 100%;
  margin-bottom: 12px;
  padding: 10px;
}

.form button {
  background: #1976d2;
  color: white;
  border: none;
  padding: 10px 16px;
  cursor: pointer;
}

.list {
  margin-top: 20px;
  list-style: none;
  padding: 0;
}

.list li {
  border-bottom: 1px solid #ddd;
  padding: 10px 0;
}
</style>
