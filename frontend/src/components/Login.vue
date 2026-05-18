<template>
  <div class="auth">
    <h2>Ienākt</h2>

    <input v-model="email" placeholder="Email" />
    <input v-model="password" type="password" placeholder="Parole" />

    <button @click="login">Ienākt</button>
  </div>
</template>

<script>
import api from "@/api"

export default {
  data() {
    return {
      email: "",
      password: ""
    }
  },

  methods: {
    async login() {
      try {
        const response = await api.post("/login", {
          email: this.email,
          password: this.password
        })

        alert("Ienākšana veiksmīga")
      } catch (e) {
        console.error(e)
        alert("Kļūda")
      }
    }
  }
}
</script>
