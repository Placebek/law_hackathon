import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '../components/Home/HomePage.vue'
import Department from '../components/department/Department.vue'
import Statistics from '../components/statistics/Statistics.vue'
import ProfilePage from '../components/profile/ProfilePage.vue'

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
  {
    path: '/profile',
    name: 'ProfilePage',
    component: ProfilePage,
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
