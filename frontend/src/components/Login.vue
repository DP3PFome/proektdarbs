<template>

<div class="auth">

<h2>Ienākt</h2>

<input v-model="email" placeholder="Email">
<input v-model="password" type="password" placeholder="Parole">

<button @click="login">Ienākt</button>

</div>

</template>

<script>

import axios from "axios"

const API_BASE = `http://${window.location.hostname}:8000`

export default{

data(){
return{
email:"",
password:""
}
},

methods:{

async login(){

try{

const res = await axios.post(
`${API_BASE}/api/login`,
{
email:this.email,
password:this.password
}
)

alert("Login veiksmīgs")

}catch(e){

alert("Nepareizs email vai parole")

}

}

}

}

</script>
