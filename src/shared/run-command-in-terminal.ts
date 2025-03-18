import { exec } from 'child_process';

export const runCommandInTerminal = (command: string): Promise<void> => {
  return new Promise((resolve, reject) => {

    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.log(`error: ${error.message}`);
        return reject()
      }

      if (stderr) {
        console.log(`stderr: ${stderr}`);
        return reject()
      }
      console.log(`stdout: ${stdout}`);
      return resolve()
    })
  })
}

