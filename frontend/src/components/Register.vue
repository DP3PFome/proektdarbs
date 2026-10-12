<template>
  <div class="auth">
    <h2>Reģistrācija</h2>

    <input v-model="name" placeholder="Vārds" />
    <input v-model="email" placeholder="Email" />
    <input v-model="password" type="password" placeholder="Parole" />

    <button @click="register">Izveidot kontu</button>
  </div>
</template>

<script>
import api from "@/api"

export default {
  data() {
    return {
      name: "",
      email: "",
      password: ""
    }
  },

  methods: {
    async register() {
      try {
        await api.post("/register", {
          name: this.name,
          email: this.email,
          password: this.password
        })

        alert("Konts izveidots")
      } catch (e) {
        console.error(e)
        const errors = e.response?.data?.errors
        const message = errors
          ? Object.values(errors).flat().join("\n")
          : e.response?.data?.message ?? "Reģistrācija neizdevās. Pārbaudiet savienojumu ar serveri."
        alert(message)
      }
    }
  }
}
</script>
