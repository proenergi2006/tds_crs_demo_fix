// resources/@client/stores/auth.ts
import { defineStore } from 'pinia'
import axios from 'axios'
import router from '@/router'
import Swal from 'sweetalert2'

let idleTimer: number | undefined
const IDLE_LIMIT = 5 * 60 * 1000 // 5 menit


export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as { id:string;name: string; email: string;  id_role: number;  two_factor_secret: string | null } | null,
  }),
  actions: {
    async fetchUser() {
      try {
        const { data } = await axios.get('/api/user')
        this.user = data
        //this.startIdleTimer() // ⬅️ TAMBAHAN AMAN
      } catch {
        this.user = null
      }
    },
   
    clear() {
      this.user = null
      localStorage.removeItem('access_token')
      delete axios.defaults.headers.common['Authorization']
      this.stopIdleTimer() // ⬅️ TAMBAHAN AMAN
    },

    // =====================
    // FUNGSI BARU (TAMBAHAN)
    // =====================
    startIdleTimer() {
      this.stopIdleTimer()

      idleTimer = window.setTimeout(() => {
        this.forceLogout()
      }, IDLE_LIMIT)
    },

    resetIdleTimer() {
      if (this.user) {
        this.startIdleTimer()
      }
    },

    stopIdleTimer() {
      if (idleTimer) {
        clearTimeout(idleTimer)
        idleTimer = undefined
      }
    },
    forceLogout() {
      // hentikan timer
      this.stopIdleTimer()
    
      Swal.fire({
        icon: 'warning',
        title: 'Session Expired',
        text: 'Your session has expired due to inactivity. Please login again.',
        confirmButtonText: 'OK',
        allowOutsideClick: false,
        allowEscapeKey: false,
      }).then(() => {
        // logout bersih
        this.clear()
    
        router.push({
          name: 'login',
          query: { logged_out: '1' }
        })
      })
    }
  }
})
