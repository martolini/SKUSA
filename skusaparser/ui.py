from Tkinter import *
from ttk import *
from tkFileDialog import askopenfilename
import tkMessageBox
from Queue import Queue
from parse import *


class Example(Frame):

	def __init__(self, parent):
		Frame.__init__(self, parent)   
		self.y = 50
		self.parent = parent
		self.host = StringVar()
		self.user = StringVar()
		self.password = StringVar()
		self.port = StringVar()
		self.db = StringVar()
		self.eventnames = StringVar()
		self.filename = None
		self.statusvar = StringVar()
		self.tot = 0

		self.initUI()

	def makeentry(self, parent, caption, width=None, **options):
		l = Label(parent, text=caption)
		l.pack(side=LEFT)
		l.place(x=10, y=self.y)
		entry = Entry(parent, **options)
		if width:
			entry.config(width=width)
		entry.pack(side=LEFT)
		entry.place(x=250, y=self.y)
		self.y += 40
		return entry
		
	def initUI(self):
	  
		self.parent.title("SKUSA Database importer")
		self.style = Style()
		self.style.theme_use("aqua")

		self.pack(fill=BOTH, expand=1)
		self.prog_bar = Progressbar(
			self.parent, orient='horizontal', length=300, mode='determinate')
		self.prog_bar.pack(side=BOTTOM)
		self.prog_bar['value'] = 0


		fileButton = Button(self, text="Select a CSV-file", command=self.clickedFileButton).pack()

		self.makeentry(self, "Host: ", textvariable=self.host)
		self.makeentry(self, "Username: ", textvariable=self.user)
		self.makeentry(self, "Password: ", textvariable=self.password)
		self.makeentry(self, "Port: ", textvariable=self.port)
		self.makeentry(self, "Database: ", textvariable=self.db)
		self.makeentry(self, "Event names (comma separated): ", textvariable=self.eventnames)

		self.host.set('127.0.0.1')
		self.user.set('root')
		self.password.set('skusaroot')
		self.port.set('3306')
		self.db.set('skusa')
		self.eventnames.set('Event 1, Event 2')
		self.b = Button(self, text='Run', command=self.clickedRun)
		self.b.place(x=250, y=self.y)
		l = Label(self, textvariable=self.statusvar).pack()
		self.statusvar.set("Status: Waiting for file!")

	def clickedFileButton(self):
		self.filename = askopenfilename()
		if not self.filename.endswith('csv'):
			tkMessageBox.showinfo("Error", "This is not a CSV file.")
			self.filename = None


	def clickedRun(self):
		if not (self.filename and self.host.get() and self.user.get() and self.password.get() and self.db.get() and self.port.get() and self.eventnames.get()):
			message = ""
			if not self.filename:
				message += "Please select a CSV file.\n"
			if not self.host.get():
				message += 'Please insert a host.\n'
			if not self.user.get():
				message += 'Please insert a username.\n'
			if not self.password.get():
				message += 'Please insert a password.\n'
			if not self.db.get():
				message += 'Please insert a database.\n'
			if not self.port.get():
				message += 'Please insert a port.\n'
			if not self.eventnames.get():
				message += "Please set some event names.\n"
			tkMessageBox.showerror("Error", message)
			return False
		self.prog_bar['value'] = 0
		self.queue = Queue()
		self.b['state'] = 'disabled'
		try:
			parser = Parser(self.filename, self.host.get(), self.user.get(), self.password.get(), self.db.get(), int(self.port.get()), self.eventnames.get(), self.queue)
			parser.start()
			self.parent.after(100, self.process_queue)
			self.statusvar.set("Status: IMPORTING! Please wait...")
		except Exception, e:
			tkMessageBox.showinfo("Error", "{}\r\nShow this message to the administrator.".format(e))
			self.b['state'] = 'enabled'

	def process_queue(self):
		try:
			prog = self.queue.get(0)
			self.prog_bar['value'] = prog
		except:
			pass
		if abs(self.prog_bar['value'] - 100) > 0.1:
			self.parent.after(100, self.process_queue)
		else:
			tkMessageBox.showinfo("Success!", "Successfully imported csv into the database!")
			self.statusvar.set("Done!")
			self.b['state'] = 'enabled'



def main():
  
	root = Tk()
	root.geometry("600x400+300+300")
	app = Example(root)
	root.mainloop()  


if __name__ == '__main__':
	main()  