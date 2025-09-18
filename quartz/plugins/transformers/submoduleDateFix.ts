import { QuartzTransformerPlugin } from "../types"
import fs from "fs"

export interface Options {
  submodulePaths: string[]
}

const defaultOptions: Options = {
  submodulePaths: ["Android-Notes", "CS-Notes"]
}

export const SubmoduleDateFix: QuartzTransformerPlugin<Partial<Options>> = (userOpts) => {
  const opts = { ...defaultOptions, ...userOpts }
  return {
    name: "SubmoduleDateFix",
    markdownPlugins(ctx) {
      return [
        () => {
          return async (_tree, file) => {
            const fp = file.data.relativePath!
            const isSubmoduleFile = opts.submodulePaths.some(subPath =>
              fp.startsWith(subPath + "/") || fp === subPath
            )

            if (isSubmoduleFile) {
              if (!file.data.frontmatter) {
                file.data.frontmatter = {}
              }

              const fullFp = file.data.filePath!
              const st = await fs.promises.stat(fullFp)

              // Use current date if filesystem date is Unix epoch (invalid)
              const isEpochDate = (date: Date) => date.getTime() === 0 || date.getFullYear() === 1970
              const currentDate = new Date().toISOString()

              if (!file.data.frontmatter.created || file.data.frontmatter.created === "0") {
                file.data.frontmatter.created = isEpochDate(st.birthtime) ? currentDate : st.birthtime.toISOString()
              }

              if (!file.data.frontmatter.modified || file.data.frontmatter.modified === "0") {
                file.data.frontmatter.modified = isEpochDate(st.mtime) ? currentDate : st.mtime.toISOString()
              }

              if (!file.data.frontmatter.date || file.data.frontmatter.date === "0") {
                file.data.frontmatter.date = isEpochDate(st.mtime) ? currentDate : st.mtime.toISOString()
              }
            }
          }
        },
      ]
    },
  }
}