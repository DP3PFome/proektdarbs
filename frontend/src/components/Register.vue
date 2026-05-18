<template>

<div class="auth">

<h2>Reģistrācija</h2>

<input v-model="name" placeholder="Vārds">
<input v-model="email" placeholder="Email">
<input v-model="password" type="password" placeholder="Parole">

<button @click="register">Izveidot kontu</button>

</div>

</template>

<script>

import axios from "axios"

const API_BASE = `import.meta.env.VITE_API_URL`

export default{

data(){
return{
name:"",
email:"",
password:""
}
},

methods:{

async register(){

try{

await axios.post(
`${API_BASE}/api/register`,
{
name:this.name,
email:this.email,
password:this.password
}
)

alert("Konts izveidots")

}catch(e){

alert("Kļūda")

}

}

}

}

</script>
