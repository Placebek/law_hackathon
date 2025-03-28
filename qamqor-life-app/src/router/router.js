import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '../components/Home/HomePage.vue'
import Department from '../components/department/Department.vue'
import Statistics from '../components/statistics/Statistics.vue'

const routes = [
  {
    path: '/home',
    name: 'HomePage',
    component: HomePage,
  },
  {
    path: '/department',
    name: 'Department',
    component: Department,
  },
  {
    path: '/statistics',
    name: 'Statistics',
    component: Statistics,
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
