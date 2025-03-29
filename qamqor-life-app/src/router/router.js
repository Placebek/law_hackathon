import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '../components/Home/HomePage.vue'
import Department from '../components/department/Department.vue'
import Statistics from '../components/statistics/Statistics.vue'
import ProfilePage from '../components/profile/ProfilePage.vue'
import StatementPage from '../components/statement/StatementPage.vue'

const routes = [
  {
    path: '/home',
    name: 'HomePage',
    component: HomePage,
  },
  {
    path: '/department/:id',
    name: 'Department',
    component: Department,
  },
  {
    path: '/statistics',
    name: 'Statistics',
    component: Statistics,
  },
  {
    path: '/profile/:id',
    name: 'ProfilePage',
    component: ProfilePage,
  },
  {
    path: '/statement/:id',
    name: 'StatementPage',
    component: StatementPage,
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
