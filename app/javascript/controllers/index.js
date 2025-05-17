// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from 'controllers/application'

import BooksController from './books_controller'
application.register('books', BooksController)

import { eagerLoadControllersFrom } from '@hotwired/stimulus-loading'
eagerLoadControllersFrom('controllers', application)
