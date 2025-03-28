import { createApp } from 'vue';
import { OhVueIcon, addIcons } from "oh-vue-icons";
import { FaFlag, RiZhihuFill } from "oh-vue-icons/icons";

import './style.css'
import App from './App.vue'
import router from './router/router.js'

import VCalendar from 'v-calendar'
import 'v-calendar/style.css'

addIcons(FaFlag, RiZhihuFill);

createApp(App)
  .use(router)
  .use(VCalendar, {})
  .component("v-icon", OhVueIcon) 
  .mount('#app')